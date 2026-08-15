import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/domain/entities/video_source.dart';
import 'package:tv_overlay_refactor_task/presentation/player/view/player_screen.dart';
import 'package:tv_overlay_refactor_task/presentation/tv_overlay/cubit/overlay_visibility_cubit.dart';
import 'package:tv_overlay_refactor_task/presentation/tv_overlay/view/tv_overlay.dart';

import '../../../fakes/fake_playback_service.dart';

/// Widget tests for the behaviours TASK.md requires, driven through real key
/// events against the full player screen with a fake playback service.
void main() {
  const source = VideoSource(url: 'https://example.test/a.m3u8', title: 'Film');

  late FakePlaybackService playback;

  /// Pumps the player and settles it into the ready, playing state.
  Future<void> pumpPlayer(WidgetTester tester) async {
    playback = FakePlaybackService();
    await tester.pumpWidget(
      MaterialApp(
        home: PlayerScreen(
          source: source,
          createPlayback: (_) =>
              (service: playback, surface: const SizedBox.shrink()),
        ),
      ),
    );
    // Reports flow through the bloc, the overlay mounts, initial focus lands.
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  Future<void> unmount(WidgetTester tester) =>
      tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

  String? focusedLabel() => FocusManager.instance.primaryFocus?.debugLabel;

  OverlayVisibilityCubit overlayOf(WidgetTester tester) =>
      BlocProvider.of<OverlayVisibilityCubit>(
        tester.element(find.byType(TvOverlay)),
      );

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  /// Drives playback into the intro window and rebuilds.
  Future<void> reachIntroWindow(WidgetTester tester) async {
    playback.report(
      playback.value.copyWith(
        position: const Duration(seconds: 12),
        duration: const Duration(minutes: 10),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('opens with the overlay shown and play/pause focused', (
    tester,
  ) async {
    await pumpPlayer(tester);

    expect(overlayOf(tester).state, isTrue);
    expect(focusedLabel(), 'overlay.playPause');

    await unmount(tester);
  });

  testWidgets('D-pad walks between the zones', (tester) async {
    await pumpPlayer(tester);

    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedLabel(), 'overlay.progress');

    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedLabel(), 'overlay.playPause');

    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedLabel(), 'overlay.back');

    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedLabel(), 'overlay.playPause');

    await unmount(tester);
  });

  testWidgets('left and right on the progress bar seek by 15 seconds', (
    tester,
  ) async {
    await pumpPlayer(tester);
    await press(tester, LogicalKeyboardKey.arrowDown);
    playback.calls.clear();

    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(playback.calls, contains('seekBy 0:00:15.000000'));

    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(playback.calls, contains('seekBy -0:00:15.000000'));

    await unmount(tester);
  });

  testWidgets('hides after five idle seconds of playback, any key revives', (
    tester,
  ) async {
    await pumpPlayer(tester);

    await tester.pump(const Duration(seconds: 5));
    expect(overlayOf(tester).state, isFalse);

    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(overlayOf(tester).state, isTrue);

    await unmount(tester);
  });

  testWidgets('stays visible while paused', (tester) async {
    await pumpPlayer(tester);

    // Select on the focused play/pause button pauses.
    await press(tester, LogicalKeyboardKey.enter);
    expect(playback.value.isPlaying, isFalse);

    await tester.pump(const Duration(seconds: 6));
    expect(overlayOf(tester).state, isTrue);

    await unmount(tester);
  });

  testWidgets('Skip intro exists only inside the 10–20s window', (
    tester,
  ) async {
    await pumpPlayer(tester);

    expect(find.text('Skip intro'), findsNothing);

    await reachIntroWindow(tester);
    expect(find.text('Skip intro'), findsOneWidget);

    playback.report(
      playback.value.copyWith(position: const Duration(seconds: 25)),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Skip intro'), findsNothing);

    await unmount(tester);
  });

  testWidgets('hiding during the intro hands focus to Skip intro', (
    tester,
  ) async {
    await pumpPlayer(tester);
    await reachIntroWindow(tester);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(overlayOf(tester).state, isFalse);
    expect(focusedLabel(), 'overlay.skipIntro');

    await unmount(tester);
  });

  testWidgets('Select on Skip intro jumps to the 20th second', (tester) async {
    await pumpPlayer(tester);
    await reachIntroWindow(tester);

    // Up from the action row goes to the intro button while it is on screen.
    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedLabel(), 'overlay.skipIntro');
    playback.calls.clear();

    await press(tester, LogicalKeyboardKey.enter);
    expect(playback.calls, contains('seekTo 0:00:20.000000'));

    await unmount(tester);
  });
}
