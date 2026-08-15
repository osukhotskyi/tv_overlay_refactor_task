import 'package:equatable/equatable.dart';

class PlayerValue extends Equatable {
  const PlayerValue({
    this.position = Duration.zero,
    this.duration,
    this.isPlaying = false,
    this.isLoading = true,
    this.initialized = false,
    this.errorDescription,
    this.aspectRatio = 16 / 9,
  });

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
