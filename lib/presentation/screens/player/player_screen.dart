import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/video_source.dart';
import '../../../domain/services/playback_service.dart';
import 'bloc/player_bloc.dart';
import 'overlay/cubit/overlay_visibility_cubit.dart';
import 'overlay/tv_overlay.dart';

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
      create: (_) => PlayerBloc(source: widget.source, playback: _playback.service)..add(const PlayerStarted()),
      child: _PlayerView(videoSurface: _playback.surface),
    );
  }
}

/// Renders whatever the [PlayerBloc] above reports: the screen owns
/// lifecycle and wiring, this owns layout.
class _PlayerView extends StatelessWidget {
  const _PlayerView({required this.videoSurface});

  final Widget videoSurface;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // A selector, not a plain builder: position ticks change the state
      // several times a second, and this branch cares about three slow
      // fields only. Without it the whole body would rebuild every tick,
      // kept in check solely by `const TvOverlay()` canonicalisation.
      body: BlocSelector<PlayerBloc, PlayerState, ({String? error, bool initialized, double aspectRatio})>(
        selector: (state) => (
          error: state.value.errorDescription,
          initialized: state.value.initialized,
          aspectRatio: state.value.aspectRatio,
        ),
        builder: (context, data) {
          final error = data.error;
          if (error != null) {
            return _ErrorView(message: error);
          }

          if (!data.initialized) {
            return const _LoadingView();
          }

          return _VideoWithOverlay(
            aspectRatio: data.aspectRatio,
            videoSurface: videoSurface,
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _VideoWithOverlay extends StatelessWidget {
  const _VideoWithOverlay({
    required this.aspectRatio,
    required this.videoSurface,
  });

  /// The video's own proportions, reported by the stream; the screen's
  /// proportions are handled by layout (Center + AspectRatio letterboxes).
  final double aspectRatio;
  final Widget videoSurface;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(aspectRatio: aspectRatio, child: videoSurface),
        ),
        BlocProvider(
          create: (context) {
            final player = context.read<PlayerBloc>();
            return OverlayVisibilityCubit(
              isPlaying: () => player.state.value.isPlaying,
            );
          },
          child: const TvOverlay(),
        ),
      ],
    );
  }
}
