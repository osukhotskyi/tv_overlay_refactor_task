import 'package:equatable/equatable.dart';

/// The film to play: where the stream lives and how to name it in the UI.
class VideoSource extends Equatable {
  const VideoSource({required this.url, required this.title});

  final String url;
  final String title;

  @override
  List<Object?> get props => [url, title];
}
