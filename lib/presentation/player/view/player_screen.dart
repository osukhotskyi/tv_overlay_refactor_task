import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../domain/entities/device_info.dart';
import '../../../domain/entities/video_source.dart';
import '../../tv_overlay/cubit/overlay_visibility_cubit.dart';
import '../../tv_overlay/view/tv_overlay_old.dart';
import '../bloc/player_bloc.dart';

/// Owns the [PlayerBloc] for the film it is given.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({required this.source, super.key});

  final VideoSource source;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerBloc(
        source: source,
        // Read here rather than inside the bloc: a bloc has no BuildContext,
        // and pulling dependencies from an ambient store would hide them from
        // its constructor and from tests.
        //
        // TODO(refactor): the emulator flag is a detail of how video is
        // rendered. It leaves this file once PlayerBloc receives a ready
        // playback service instead of building one itself.
        isEmulator: context.read<DeviceInfo>().isEmulator,
      )..add(const PlayerStarted()),
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
              BlocProvider(
                create: (_) => OverlayVisibilityCubit(
                  isPlaying: state.value?.isPlaying ?? false,
                ),
                child: const TvOverlayOld(),
              ),
            ],
          );
        },
      ),
    );
  }
}
