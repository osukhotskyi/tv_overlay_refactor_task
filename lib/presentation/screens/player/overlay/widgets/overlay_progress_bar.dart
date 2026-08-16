import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../widgets/player_focus_decoration.dart';
import '../../../../utils/duration_label.dart';

/// How far one left/right press jumps.
const _seekStep = Duration(seconds: 15);

/// Tabular figures keep the labels from changing width as digits tick over.
const _timeStyle = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

/// The seek bar of the overlay: a focus scope wearing the standard highlight.
///
/// Listens to its own node, so the highlight updates the moment focus moves
/// rather than whenever the next position tick happens to rebuild it.
class OverlayProgressBar extends StatefulWidget {
  const OverlayProgressBar({
    required this.position,
    required this.duration,
    required this.node,
    required this.onSeek,
    required this.onFocusUp,
    super.key,
  });

  final Duration position;
  final Duration duration;
  final FocusScopeNode node;

  /// Seeking is this widget's own business: it decides that left and right
  /// mean ±[_seekStep] and simply reports the jump.
  final ValueChanged<Duration> onSeek;

  /// Leaving upwards is not — where that leads is the overlay's decision.
  final VoidCallback onFocusUp;

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

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        widget.onSeek(-_seekStep);
      case LogicalKeyboardKey.arrowRight:
        widget.onSeek(_seekStep);
      case LogicalKeyboardKey.arrowUp:
        widget.onFocusUp();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: widget.node,
      onKeyEvent: _onKeyEvent,
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
        Text(position.asTimeLabel, style: _timeStyle),
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
        Text(duration.asTimeLabel, style: _timeStyle),
      ],
    );
  }
}
