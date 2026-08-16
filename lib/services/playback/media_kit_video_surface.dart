import 'package:flutter/widgets.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Renders a media_kit [VideoController].
///
/// Rendering needs the plugin's own controller, which cannot be expressed in
/// a pure-Dart interface. Keeping the widget here, next to the plugin, means
/// the player screen receives a plain [Widget] and never imports media_kit —
/// which is what makes the screen testable.
///
/// Takes just the controller — the narrowest input that suffices. Ownership
/// was never here: the screen creates and disposes the service; this widget
/// only draws.
class MediaKitVideoSurface extends StatelessWidget {
  const MediaKitVideoSurface({required this.controller, super.key});

  final VideoController controller;

  @override
  Widget build(BuildContext context) {
    return Video(controller: controller, controls: NoVideoControls);
  }
}
