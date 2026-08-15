import 'package:flutter/material.dart';

import '../../../core/utils/duration_format.dart';
import '../../common/player_focus_decoration.dart';

/// The seek bar of the overlay: a focus scope wearing the standard highlight.
///
/// Listens to its own node, so the highlight updates the moment focus moves
/// rather than whenever the next position tick happens to rebuild it.
class OverlayProgressBar extends StatefulWidget {
  const OverlayProgressBar({
    required this.position,
    required this.duration,
    required this.node,
    super.key,
  });

  final Duration position;
  final Duration duration;
  final FocusScopeNode node;

  @override
  State<OverlayProgressBar> createState() => _OverlayProgressBarState();
}

class _OverlayProgressBarState extends State<OverlayProgressBar> {
  @override
  void initState() {
    super.initState();
    widget.node.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(OverlayProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node == widget.node) return;
    oldWidget.node.removeListener(_rebuild);
    widget.node.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.node.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: widget.node,
      child: PlayerFocusDecoration(
        hasFocus: widget.node.hasFocus,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: _Bar(position: widget.position, duration: widget.duration),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.position, required this.duration});

  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final current = position.inMilliseconds
        .clamp(0, duration.inMilliseconds)
        .toDouble();

    return Row(
      children: [
        Text(formatDuration(position)),
        const SizedBox(width: 16),
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 6,
            value: max == 0 ? 0 : current / max,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
          ),
        ),
        const SizedBox(width: 16),
        Text(formatDuration(duration)),
      ],
    );
  }
}
