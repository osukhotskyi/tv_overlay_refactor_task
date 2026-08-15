import 'package:equatable/equatable.dart';

// TODO(refactor): `showOverlay` is presentation state and does not belong to a
// domain entity. It moves to OverlayVisibilityCubit in the next step.
class PlayerValue extends Equatable {
  const PlayerValue({
    this.position = Duration.zero,
    this.duration,
    this.isPlaying = false,
    this.isLoading = true,
    this.initialized = false,
    this.showOverlay = false,
    this.sliderValue = 0,
    this.errorDescription,
    this.aspectRatio = 16 / 9,
  });

  final Duration position;
  final Duration? duration;
  final bool isPlaying;
  final bool isLoading;
  final bool initialized;
  final bool showOverlay;
  final double sliderValue;
  final String? errorDescription;
  final double aspectRatio;

  PlayerValue copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
    bool? initialized,
    bool? showOverlay,
    double? sliderValue,
    String? errorDescription,
    double? aspectRatio,
  }) {
    return PlayerValue(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      initialized: initialized ?? this.initialized,
      showOverlay: showOverlay ?? this.showOverlay,
      sliderValue: sliderValue ?? this.sliderValue,
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
    showOverlay,
    sliderValue,
    errorDescription,
    aspectRatio,
  ];
}
