import 'dart:async';

import 'package:tv_overlay_refactor_task/domain/entities/player_value.dart';
import 'package:tv_overlay_refactor_task/domain/services/playback_service.dart';

/// A [PlaybackService] that records what it was asked to do and lets a test
/// push state changes by hand. No native player involved.
class FakePlaybackService implements PlaybackService {
  final _changes = StreamController<PlayerValue>.broadcast();

  /// Every call made on this service, in order.
  final calls = <String>[];

  PlayerValue _value = const PlayerValue();

  @override
  PlayerValue get value => _value;

  @override
  Stream<PlayerValue> get changes => _changes.stream;

  /// Pretends the player reported something new.
  void report(PlayerValue value) {
    _value = value;
    _changes.add(value);
  }

  @override
  Future<void> initialize() async {
    calls.add('initialize');
    report(_value.copyWith(initialized: true, isLoading: false));
  }

  @override
  Future<void> play() async {
    calls.add('play');
    report(_value.copyWith(isPlaying: true));
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    report(_value.copyWith(isPlaying: false));
  }

  @override
  Future<void> seekTo(Duration position) async {
    calls.add('seekTo $position');
    report(_value.copyWith(position: position));
  }

  @override
  Future<void> seekBy(Duration offset) async {
    calls.add('seekBy $offset');
    final next = _value.position + offset;
    report(
      _value.copyWith(position: next < Duration.zero ? Duration.zero : next),
    );
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    await _changes.close();
  }
}
