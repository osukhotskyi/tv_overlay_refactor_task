import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../tv_overlay/view/tv_overlay_old.dart';
import '../bloc/player_bloc.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

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
