import 'package:equatable/equatable.dart';

/// Everything the player knows about the media it is playing.
class PlayerValue extends Equatable {
  /// Every field is required: adding one later becomes a compile error at each
  /// construction site instead of a silently inherited default.
  const PlayerValue({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isLoading,
    required this.initialized,
    required this.errorDescription,
    required this.aspectRatio,
  });

  /// What is true before the player has reported anything.
  ///
  /// The assumptions live here rather than hiding in parameter defaults, so
  /// the starting state can be read in one place.
  const PlayerValue.initial()
    : position = Duration.zero,
      duration = null,
      isPlaying = false,
      // Nothing has been opened yet, so the player counts as busy.
      isLoading = true,
      initialized = false,
      errorDescription = null,
      // A guess until the real video parameters arrive; it only decides the
      // frame the video is laid out in.
      aspectRatio = 16 / 9;

  final Duration position;
  final Duration? duration;
  final bool isPlaying;
  final bool isLoading;
  final bool initialized;
  final String? errorDescription;
  final double aspectRatio;

  PlayerValue copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
    bool? initialized,
    String? errorDescription,
    double? aspectRatio,
  }) {
    return PlayerValue(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      initialized: initialized ?? this.initialized,
      errorDescription: errorDescription ?? this.errorDescription,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  @override
  List<Object?> get props => [
    position,
    duration,
    isPlaying,
    isLoading,
    initialized,
    errorDescription,
    aspectRatio,
  ];
}
