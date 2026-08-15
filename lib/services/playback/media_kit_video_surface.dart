import 'package:flutter/widgets.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'media_kit_playback_service.dart';

/// Renders the video of a [MediaKitPlaybackService].
///
/// Rendering needs the plugin's own controller, which cannot be expressed in
/// a pure-Dart interface. Keeping it in a widget here means the player screen
/// receives a plain [Widget] and never imports media_kit — which is what makes
/// the screen testable.
class MediaKitVideoSurface extends StatelessWidget {
  const MediaKitVideoSurface({required this.service, super.key});

  final MediaKitPlaybackService service;

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: service.videoController,
      controls: NoVideoControls,
    );
  }
}
