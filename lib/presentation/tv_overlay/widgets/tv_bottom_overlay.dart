import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets.dart';
import '../../player/bloc/player_bloc.dart';
import '../cubit/overlay_visibility_cubit.dart';
import '../focus/overlay_focus_controller.dart';

class TvBottomOverlay extends StatelessWidget {
  const TvBottomOverlay({required this.focus, super.key});

  final OverlayFocusController focus;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FocusScope(
          node: focus.actions,
          child: Row(
            children: [
              BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (previous, current) =>
                    previous.value.isPlaying != current.value.isPlaying,
                builder: (context, state) {
                  return FocusWrapper(
                    focusNode: focus.playPause,
                    autofocus: true,
                    onTap: () => context.read<PlayerBloc>().add(
                      const PlayerPlayPauseToggled(),
                    ),
                    builder: (context, hasFocus, child) =>
                        PlayerFocusDecoration(
                          hasFocus: hasFocus,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              state.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 30,
                            ),
                          ),
                        ),
                  );
                },
              ),
              const Spacer(),
              DefaultPlayerButton(
                title: 'Audio and subtitles',
                icon: Icons.subtitles,
                onTap: () => _showDialog(context, 'Audio and subtitles'),
              ),
              const SizedBox(width: 16),
              DefaultPlayerButton(
                title: 'Settings',
                icon: Icons.settings,
                onTap: () => _showDialog(context, 'Settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<PlayerBloc, PlayerState>(
          buildWhen: (previous, current) =>
              previous.value.position != current.value.position ||
              previous.value.duration != current.value.duration,
          builder: (context, state) => FramePlayerProgressBar(
            position: state.value.position,
            duration: state.value.duration ?? Duration.zero,
            node: focus.progress,
          ),
        ),
      ],
    );
  }

  Future<void> _showDialog(BuildContext context, String title) async {
    final overlay = context.read<OverlayVisibilityCubit>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('This action is intentionally left as a stub.'),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    // Closing a dialog is user activity: bring the controls back and restart
    // the countdown. The old code toggled, so it hid them instead whenever
    // they were still up.
    overlay.notifyUserActivity();
  }
}
