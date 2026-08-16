import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The one focusable primitive of the UI: takes focus, fires [onTap] on
/// Select/Enter or a tap, and rebuilds its content whenever focus changes.
///
/// Everything clickable is built on top of this, so key handling lives in a
/// single place.
class FocusWrapper extends StatefulWidget {
  const FocusWrapper({
    required this.onTap,
    required this.builder,
    this.focusNode,
    this.onDirectionalKey,
    this.debugLabel,
    super.key,
  });

  final VoidCallback onTap;

  /// Supply a node when something outside needs to move focus here; otherwise
  /// the widget creates and owns one.
  final FocusNode? focusNode;

  /// Consulted for keys this widget does not claim itself — directional
  /// navigation, typically.
  ///
  /// It has to arrive as a callback rather than being set on the node: a
  /// [Focus] widget overwrites `FocusNode.onKeyEvent` when it attaches, so a
  /// handler installed on the node would silently never run.
  final KeyEventResult Function(KeyEvent event)? onDirectionalKey;

  final String? debugLabel;
  final Widget Function(BuildContext context, bool hasFocus, Widget? child)
  builder;

  @override
  State<FocusWrapper> createState() => _FocusWrapperState();
}

class _FocusWrapperState extends State<FocusWrapper> {
  FocusNode? _owned;
  late FocusNode _node =
      widget.focusNode ?? (_owned = FocusNode(debugLabel: widget.debugLabel));

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    _node.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(FocusWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A swapped-in external node (or its removal) must take the listener
    // along, or the highlight keeps following the old node. An owned node is
    // kept for reuse and released in dispose.
    final next =
        widget.focusNode ??
        (_owned ??= FocusNode(debugLabel: widget.debugLabel));
    if (identical(next, _node)) return;
    _node.removeListener(_rebuild);
    _node = next..addListener(_rebuild);
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
      onKeyEvent: (_, event) {
        if (_isSubmit(event)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return widget.onDirectionalKey?.call(event) ?? KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.builder(context, _node.hasFocus, null),
      ),
    );
  }
}

bool _isSubmit(KeyEvent event) =>
    event is KeyDownEvent &&
    (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select);
