import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../domain/entities/player_value.dart';
import '../../domain/services/playback_service.dart';

class MediaKitPlaybackService implements PlaybackService {
  MediaKitPlaybackService(this.url, {required bool isEmulator})
    : player = Player() {
    videoController = VideoController(
      player,
      // Emulators cannot render through libmpv's OpenGL path: creating the
      // EGL context fails on the guest driver (media-kit#1343). Letting
      // MediaCodec draw straight into the Surface skips EGL entirely.
      configuration: isEmulator
          ? const VideoControllerConfiguration(
              vo: 'mediacodec_embed',
              hwdec: 'mediacodec',
            )
          : const VideoControllerConfiguration(),
    );
    _subscriptions.addAll([
      player.stream.position.listen((position) => _update(position: position)),
      player.stream.duration.listen((duration) => _update(duration: duration)),
      player.stream.playing.listen(
        (playing) => _emit(_value.copyWith(isPlaying: playing)),
      ),
      player.stream.buffering.listen(
        (buffering) => _emit(_value.copyWith(isLoading: buffering)),
      ),
      player.stream.width.listen((width) {
        _width = width;
        _updateAspectRatio();
      }),
      player.stream.height.listen((height) {
        _height = height;
        _updateAspectRatio();
      }),
      player.stream.error.listen(
        (error) => _emit(_value.copyWith(errorDescription: error)),
      ),
    ]);
  }

  final String url;
  final Player player;
  late final VideoController videoController;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final StreamController<PlayerValue> _changes =
      StreamController<PlayerValue>.broadcast();

  PlayerValue _value = const PlayerValue();
  int? _width;
  int? _height;

  @override
  PlayerValue get value => _value;

  @override
  Stream<PlayerValue> get changes => _changes.stream;

  @override
  Future<void> initialize() async {
    await player.open(Media(url), play: false);
    _emit(_value.copyWith(initialized: true, isLoading: false));
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seekTo(Duration position) => player.seek(_clamp(position));

  @override
  Future<void> seekBy(Duration offset) => seekTo(_value.position + offset);

  Duration _clamp(Duration position) {
    if (position < Duration.zero) return Duration.zero;
    final duration = _value.duration;
    if (duration != null && position > duration) return duration;
    return position;
  }

  void _emit(PlayerValue next) {
    if (next == _value) return;
    _value = next;
    if (!_changes.isClosed) _changes.add(next);
  }

  void _update({Duration? position, Duration? duration}) {
    final nextPosition = position ?? _value.position;
    final nextDuration = duration ?? _value.duration;

    _emit(_value.copyWith(position: nextPosition, duration: nextDuration));
  }

  void _updateAspectRatio() {
    if (_width == null || _height == null || _height == 0) return;
    _emit(_value.copyWith(aspectRatio: _width! / _height!));
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _changes.close();
    await player.dispose();
  }
}
