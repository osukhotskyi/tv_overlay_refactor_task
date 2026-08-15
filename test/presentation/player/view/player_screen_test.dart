import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/domain/entities/video_source.dart';
import 'package:tv_overlay_refactor_task/presentation/player/view/player_screen.dart';

import '../../../fakes/fake_playback_service.dart';

void main() {
  const source = VideoSource(url: 'https://example.test/a.m3u8', title: 'Film');

  testWidgets('releases the playback service when it goes away', (
    tester,
  ) async {
    final playback = FakePlaybackService();

    await tester.pumpWidget(
      MaterialApp(
        home: PlayerScreen(
          source: source,
          createPlayback: (_) =>
              (service: playback, surface: const SizedBox.shrink()),
        ),
      ),
    );

    expect(playback.calls, isNot(contains('dispose')));

    // The screen leaves the tree, as it would on Back.
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(playback.calls, contains('dispose'));
  });

  testWidgets('starts playback as soon as it is shown', (tester) async {
    final playback = FakePlaybackService();

    await tester.pumpWidget(
      MaterialApp(
        home: PlayerScreen(
          source: source,
          createPlayback: (_) =>
              (service: playback, surface: const SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump();

    expect(playback.calls.take(2), ['initialize', 'play']);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
  });

  testWidgets('shows a spinner until the player is ready', (tester) async {
    final playback = FakePlaybackService();

    await tester.pumpWidget(
      MaterialApp(
        home: PlayerScreen(
          source: source,
          createPlayback: (_) =>
              (service: playback, surface: const SizedBox.shrink()),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
  });
}
