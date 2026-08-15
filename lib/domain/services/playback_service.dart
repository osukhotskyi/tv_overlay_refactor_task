import '../entities/player_value.dart';

/// Plays a video and reports what it is doing.
///
/// Pure Dart on purpose: the presentation layer talks to this, never to a
/// player plugin, so the bloc and the overlay can be tested without native
/// libraries. Rendering is deliberately absent — see the video surface widget
/// in the services layer.
abstract interface class PlaybackService {
  /// The latest known state. Never null, so callers do not need `!`.
  PlayerValue get value;

  /// Emits on every change of [value].
  Stream<PlayerValue> get changes;

  /// Opens the media without starting playback.
  Future<void> initialize();

  Future<void> play();

  Future<void> pause();

  /// Jumps to [position], clamped to the media duration.
  Future<void> seekTo(Duration position);

  /// Jumps [offset] from the current position; negative seeks backwards.
  /// Clamped, so callers do not have to guard the ends themselves.
  Future<void> seekBy(Duration offset);

  Future<void> dispose();
}
