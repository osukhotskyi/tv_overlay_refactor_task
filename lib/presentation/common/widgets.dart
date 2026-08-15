import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/duration_format.dart';

extension TvKeyEventX on KeyEvent {
  bool get up => logicalKey == LogicalKeyboardKey.arrowUp;
  bool get down => logicalKey == LogicalKeyboardKey.arrowDown;

  bool get hasSubmitIntent =>
      this is KeyDownEvent &&
      (logicalKey == LogicalKeyboardKey.enter ||
          logicalKey == LogicalKeyboardKey.select);
}

class FocusWrapper extends StatefulWidget {
  const FocusWrapper({
    required this.onTap,
    required this.builder,
    this.focusNode,
    this.autofocus = false,
    this.debugLabel,
    super.key,
  });

  final VoidCallback onTap;

  /// Supply a node when something outside needs to move focus here; otherwise
  /// the widget creates and owns one.
  final FocusNode? focusNode;
  final bool autofocus;
  final String? debugLabel;
  final Widget Function(BuildContext context, bool hasFocus, Widget? child)
  builder;

  @override
  State<FocusWrapper> createState() => _FocusWrapperState();
}

class _FocusWrapperState extends State<FocusWrapper> {
  FocusNode? _owned;
  late final FocusNode _node =
      widget.focusNode ?? (_owned = FocusNode(debugLabel: widget.debugLabel));

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    _node.addListener(_rebuild);
  }

  @override
  void dispose() {
    _node.removeListener(_rebuild);
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      onKeyEvent: (_, event) {
        if (event.hasSubmitIntent) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.builder(context, _node.hasFocus, null),
      ),
    );
  }
}

class PlayerFocusDecoration extends StatelessWidget {
  const PlayerFocusDecoration({
    required this.hasFocus,
    required this.child,
    super.key,
  });

  final bool hasFocus;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: hasFocus ? Colors.white : Colors.white12,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasFocus ? Colors.white : Colors.transparent,
          width: 2,
        ),
      ),
      child: IconTheme(
        data: IconThemeData(color: hasFocus ? Colors.black : Colors.white),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: hasFocus ? Colors.black : Colors.white),
          child: child,
        ),
      ),
    );
  }
}

class PlayerButton extends StatefulWidget {
  const PlayerButton({
    required this.focusNode,
    required this.onPressed,
    required this.child,
    super.key,
  });

  final FocusNode focusNode;
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<PlayerButton> createState() => _PlayerButtonState();
}

class _PlayerButtonState extends State<PlayerButton> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(PlayerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) return;
    oldWidget.focusNode.removeListener(_rebuild);
    widget.focusNode.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: PlayerFocusDecoration(
          hasFocus: widget.focusNode.hasFocus,
          child: widget.child,
        ),
      ),
    );
  }
}

class DefaultPlayerButton extends StatelessWidget {
  const DefaultPlayerButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.node,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final FocusNode? node;

  @override
  Widget build(BuildContext context) {
    if (node != null) {
      return PlayerButton(
        focusNode: node!,
        onPressed: onTap,
        child: _content(),
      );
    }

    return FocusWrapper(
      onTap: onTap,
      builder: (_, hasFocus, _) =>
          PlayerFocusDecoration(hasFocus: hasFocus, child: _content()),
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(width: 8), Text(title)],
      ),
    );
  }
}

class FramePlayerProgressBar extends StatefulWidget {
  const FramePlayerProgressBar({
    required this.position,
    required this.duration,
    required this.node,
    super.key,
  });

  final Duration position;
  final Duration duration;
  final FocusScopeNode node;

  @override
  State<FramePlayerProgressBar> createState() => _FramePlayerProgressBarState();
}

class _FramePlayerProgressBarState extends State<FramePlayerProgressBar> {
  // Listens to its own node, so the highlight no longer depends on the
  // position stream happening to rebuild this widget.
  @override
  void initState() {
    super.initState();
    widget.node.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(FramePlayerProgressBar oldWidget) {
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
          child: PlayerProgressBar(
            position: widget.position,
            duration: widget.duration,
          ),
        ),
      ),
    );
  }
}

class PlayerProgressBar extends StatelessWidget {
  const PlayerProgressBar({
    required this.position,
    required this.duration,
    super.key,
  });

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
