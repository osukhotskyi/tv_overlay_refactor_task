import 'package:equatable/equatable.dart';

/// A catalogue card: where the stream lives and how to present it.
class VideoSource extends Equatable {
  const VideoSource({
    required this.url,
    required this.title,
    this.duration,
  });

  final String url;
  final String title;

  /// Catalogue metadata, null when unknown. HLS itself carries no reliable
  /// title or presentation duration for a list — a real backend supplies
  /// these alongside the stream URL.
  final Duration? duration;

  @override
  List<Object?> get props => [url, title, duration];
}
