import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/domain/entities/player_value.dart';
import 'package:tv_overlay_refactor_task/domain/entities/video_source.dart';
import 'package:tv_overlay_refactor_task/presentation/player/bloc/player_bloc.dart';

import '../../../fakes/fake_playback_service.dart';

void main() {
  const source = VideoSource(url: 'https://example.test/a.m3u8', title: 'Film');

  late FakePlaybackService playback;
  late PlayerBloc bloc;

  setUp(() {
    playback = FakePlaybackService();
    bloc = PlayerBloc(source: source, playback: playback);
  });

  tearDown(() async {
    await bloc.close();
    await playback.dispose();
  });

  test('takes its title from the source', () {
    expect(bloc.state.contentName, 'Film');
  });

  test('starts with defaults rather than nulls', () {
    expect(bloc.state.value, const PlayerValue());
    expect(bloc.state.value.initialized, isFalse);
  });

  test('opening the player initialises it and starts playback', () async {
    bloc.add(const PlayerStarted());
    await pumpEventQueue();

    expect(playback.calls, ['initialize', 'play']);
    expect(bloc.state.value.initialized, isTrue);
    expect(bloc.state.value.isPlaying, isTrue);
  });

  test('reports from the service reach the state', () async {
    playback.report(const PlayerValue(position: Duration(seconds: 42)));
    await pumpEventQueue();

    expect(bloc.state.value.position, const Duration(seconds: 42));
  });

  test('toggling while playing pauses', () async {
    bloc.add(const PlayerStarted());
    await pumpEventQueue();
    playback.calls.clear();

    bloc.add(const PlayerPlayPauseToggled());
    await pumpEventQueue();

    expect(playback.calls, ['pause']);
    expect(bloc.state.value.isPlaying, isFalse);
  });

  test('toggling while paused plays', () async {
    bloc.add(const PlayerPlayPauseToggled());
    await pumpEventQueue();

    expect(playback.calls, ['play']);
    expect(bloc.state.value.isPlaying, isTrue);
  });

  test('seeking by an offset is forwarded as-is', () async {
    bloc.add(const PlayerSeekedBy(Duration(seconds: 15)));
    await pumpEventQueue();

    expect(playback.calls, ['seekBy 0:00:15.000000']);
  });

  test('seeking backwards past the start is left to the service', () async {
    playback.report(const PlayerValue(position: Duration(seconds: 5)));
    await pumpEventQueue();

    bloc.add(const PlayerSeekedBy(Duration(seconds: -15)));
    await pumpEventQueue();

    // The bloc does not guard the boundary itself; the service clamps.
    expect(playback.calls, contains('seekBy -0:00:15.000000'));
    expect(bloc.state.value.position, Duration.zero);
  });

  test('skipping the intro seeks to an absolute position', () async {
    bloc.add(const PlayerSeeked(Duration(seconds: 20)));
    await pumpEventQueue();

    expect(playback.calls, ['seekTo 0:00:20.000000']);
    expect(bloc.state.value.position, const Duration(seconds: 20));
  });

  test('does not own the service: closing the bloc leaves it alive', () async {
    await bloc.close();

    expect(playback.calls, isNot(contains('dispose')));
  });

  test('stops listening once closed', () async {
    await bloc.close();
    playback.report(const PlayerValue(position: Duration(seconds: 99)));
    await pumpEventQueue();

    // Would throw "Cannot emit new states after calling close" if the
    // subscription outlived the bloc.
    expect(bloc.state.value.position, Duration.zero);
  });
}
