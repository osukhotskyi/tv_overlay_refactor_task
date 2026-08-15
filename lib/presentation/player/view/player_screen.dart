import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../domain/entities/video_source.dart';
import '../../tv_overlay/view/tv_overlay_old.dart';
import '../bloc/player_bloc.dart';

/// Owns the [PlayerBloc] for the film it is given.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    required this.source,
    required this.isEmulator,
    super.key,
  });

  final VideoSource source;

  // TODO(refactor): a rendering detail of the playback service, not of the
  // screen. Disappears once the service is injected instead of constructed
  // inside the bloc.
  final bool isEmulator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PlayerBloc(source: source, isEmulator: isEmulator)
            ..add(const PlayerStarted()),
      child: const PlayerView(),
    );
  }
}

/// Renders whatever the provided [PlayerBloc] reports. Kept separate from
/// [PlayerScreen] so tests can supply their own bloc.
@visibleForTesting
class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state.value?.errorDescription != null) {
            return Center(child: Text(state.value!.errorDescription!));
          }

          if (state.value?.initialized != true) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: state.value!.aspectRatio,
                  // TODO(refactor): media_kit leaks into the presentation
                  // layer. Replaced by an injected video surface widget.
                  child: Video(
                    controller: state.controller!.videoController,
                    controls: NoVideoControls,
                  ),
                ),
              ),
              const TvOverlayOld(),
            ],
          );
        },
      ),
    );
  }
}
