import 'dart:async';

import 'package:tv_overlay_refactor_task/domain/entities/player_value.dart';
import 'package:tv_overlay_refactor_task/domain/services/playback_service.dart';

/// A [PlaybackService] that records what it was asked to do and lets a test
/// push state changes by hand. No native player involved.
///
/// Mirrors the observable semantics of MediaKitPlaybackService on purpose:
/// seeks clamp at both ends, equal values are not re-emitted, and reports
/// after dispose are ignored — so a test cannot go green on behaviour the
/// real service does not have.
class FakePlaybackService implements PlaybackService {
  final _changes = StreamController<PlayerValue>.broadcast();

  /// Every call made on this service, in order.
  final calls = <String>[];

  /// When set, [initialize] throws instead of succeeding.
  Object? initializeError;

  PlayerValue _value = const PlayerValue.initial();

  @override
  PlayerValue get value => _value;

  @override
  Stream<PlayerValue> get changes => _changes.stream;

  /// Pretends the player reported something new.
  void report(PlayerValue value) {
    if (value == _value) return;
    _value = value;
    if (!_changes.isClosed) _changes.add(value);
  }

  @override
  Future<void> initialize() async {
    calls.add('initialize');
    final error = initializeError;
    if (error != null) throw error;
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
    report(_value.copyWith(position: _clamp(position)));
  }

  @override
  Future<void> seekBy(Duration offset) async {
    calls.add('seekBy $offset');
    report(_value.copyWith(position: _clamp(_value.position + offset)));
  }

  /// The real service's bounds: never below zero, never past a known
  /// duration.
  Duration _clamp(Duration position) {
    if (position < Duration.zero) return Duration.zero;
    final duration = _value.duration;
    if (duration != null && position > duration) return duration;
    return position;
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    await _changes.close();
  }
}
