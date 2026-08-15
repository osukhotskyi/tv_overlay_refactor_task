import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/video_source.dart';
import '../../../domain/services/playback_service.dart';
import '../../tv_overlay/cubit/overlay_visibility_cubit.dart';
import '../../tv_overlay/view/tv_overlay_old.dart';
import '../bloc/player_bloc.dart';

/// A playback service together with the widget that draws its video.
///
/// The two come as a pair because rendering needs plugin internals that the
/// [PlaybackService] interface deliberately hides.
typedef Playback = ({PlaybackService service, Widget surface});

/// Owns the playback service and the bloc for the film it is given.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    required this.source,
    required this.createPlayback,
    super.key,
  });

  final VideoSource source;

  /// Injected so the screen never mentions a player plugin, which is what
  /// lets widget tests run it against a fake.
  final Playback Function(VideoSource source) createPlayback;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Playback _playback = widget.createPlayback(widget.source);

  @override
  void dispose() {
    _playback.service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PlayerBloc(source: widget.source, playback: _playback.service)
            ..add(const PlayerStarted()),
      child: PlayerView(videoSurface: _playback.surface),
    );
  }
}

/// Renders whatever the provided [PlayerBloc] reports. Kept separate from
/// [PlayerScreen] so tests can supply their own bloc and surface.
@visibleForTesting
class PlayerView extends StatelessWidget {
  const PlayerView({required this.videoSurface, super.key});

  final Widget videoSurface;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          final error = state.value.errorDescription;
          if (error != null) {
            return Center(child: Text(error));
          }

          if (!state.value.initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: state.value.aspectRatio,
                  child: videoSurface,
                ),
              ),
              BlocProvider(
                create: (context) {
                  final player = context.read<PlayerBloc>();
                  return OverlayVisibilityCubit(
                    isPlaying: () => player.state.value.isPlaying,
                  );
                },
                child: const TvOverlayOld(),
              ),
            ],
          );
        },
      ),
    );
  }
}
