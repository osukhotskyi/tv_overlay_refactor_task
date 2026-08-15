import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/player_button.dart';
import '../../player/bloc/player_bloc.dart';
import '../cubit/overlay_visibility_cubit.dart';
import '../focus/overlay_focus_controller.dart';
import 'overlay_progress_bar.dart';

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
              BlocSelector<PlayerBloc, PlayerState, bool>(
                selector: (state) => state.value.isPlaying,
                builder: (context, isPlaying) => PlayerButton(
                  focusNode: focus.playPause,
                  onPressed: () => context.read<PlayerBloc>().add(
                    const PlayerPlayPauseToggled(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PlayerLabeledButton(
                title: 'Audio and subtitles',
                icon: Icons.subtitles,
                onTap: () => _showDialog(context, 'Audio and subtitles'),
              ),
              const SizedBox(width: 16),
              PlayerLabeledButton(
                title: 'Settings',
                icon: Icons.settings,
                onTap: () => _showDialog(context, 'Settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BlocSelector<
          PlayerBloc,
          PlayerState,
          ({Duration position, Duration duration})
        >(
          selector: (state) => (
            position: state.value.position,
            duration: state.value.duration ?? Duration.zero,
          ),
          builder: (context, progress) => OverlayProgressBar(
            position: progress.position,
            duration: progress.duration,
            node: focus.progress,
            onSeek: (offset) =>
                context.read<PlayerBloc>().add(PlayerSeekedBy(offset)),
            onFocusUp: focus.focusPlayPause,
          ),
        ),
      ],
    );
  }

  Future<void> _showDialog(BuildContext context, String title) async {
    // Freeze the countdown for the dialog's lifetime: a hide while the
    // dialog is up would yank focus to Skip intro behind the barrier.
    final overlay = context.read<OverlayVisibilityCubit>()..suspendAutoHide();

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
