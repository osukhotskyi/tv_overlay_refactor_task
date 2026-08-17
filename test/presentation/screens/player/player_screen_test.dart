import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/domain/entities/video_source.dart';
import 'package:tv_overlay_refactor_task/presentation/screens/player/player_screen.dart';

import '../../../fakes/fake_playback_service.dart';

const _surfaceKey = Key('video-surface');

void main() {
  const source = VideoSource(url: 'https://example.test/a.m3u8', title: 'Film');

  Future<FakePlaybackService> pumpPlayer(WidgetTester tester) async {
    final playback = FakePlaybackService();
    await tester.pumpWidget(
      MaterialApp(
        home: PlayerScreen(
          source: source,
          createPlayback: (_) =>
              (service: playback, surface: const SizedBox(key: _surfaceKey)),
        ),
      ),
    );
    return playback;
  }

  Future<void> unmount(WidgetTester tester) =>
      tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

  testWidgets('releases the playback service when it goes away', (
    tester,
  ) async {
    final playback = await pumpPlayer(tester);

    expect(playback.calls, isNot(contains('dispose')));

    // The screen leaves the tree, as it would on Back.
    await unmount(tester);

    expect(playback.calls, contains('dispose'));
  });

  testWidgets('starts playback as soon as it is shown', (tester) async {
    final playback = await pumpPlayer(tester);
    await tester.pump();

    expect(playback.calls.take(2), ['initialize', 'play']);

    await unmount(tester);
  });

  testWidgets('swaps the spinner for the video once the player is ready', (
    tester,
  ) async {
    await pumpPlayer(tester);

    // First frame: nothing reported yet.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(_surfaceKey), findsNothing);

    // Let the fake's reports flow through the bloc and rebuild.
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(_surfaceKey), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('hiding the app pauses playback through the lifecycle listener', (
    tester,
  ) async {
    final playback = await pumpPlayer(tester);
    await tester.pump();
    await tester.pump();
    expect(playback.value.isPlaying, isTrue);

    // AppLifecycleListener enforces legal transitions; walk the real path.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();

    expect(playback.calls, contains('pause'));
    expect(playback.value.isPlaying, isFalse);

    // Coming back does not auto-resume a viewing pause.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(playback.value.isPlaying, isFalse);

    await unmount(tester);
  });

  testWidgets('shows the error text instead of the player', (tester) async {
    final playback = await pumpPlayer(tester);
    await tester.pump();
    await tester.pump();

    playback.report(
      playback.value.copyWith(errorDescription: 'demuxer: failed'),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('demuxer: failed'), findsOneWidget);
    expect(find.byKey(_surfaceKey), findsNothing);
    // The error screen must not leave the sound running behind it.
    expect(playback.calls, contains('pause'));

    await unmount(tester);
  });
}
