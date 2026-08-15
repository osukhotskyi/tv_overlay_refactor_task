import 'package:flutter/material.dart';

import 'focus_wrapper.dart';
import 'player_focus_decoration.dart';

/// A focusable button wearing the standard highlight.
///
/// Composed from [FocusWrapper] rather than repeating its focus and key
/// handling, which is what the previous pair of near-identical button
/// widgets did.
class PlayerButton extends StatelessWidget {
  const PlayerButton({
    required this.onPressed,
    required this.child,
    this.focusNode,
    this.onDirectionalKey,
    super.key,
  });

  final VoidCallback onPressed;
  final Widget child;
  final FocusNode? focusNode;

  /// See [FocusWrapper.onDirectionalKey].
  final KeyEventResult Function(KeyEvent event)? onDirectionalKey;

  @override
  Widget build(BuildContext context) {
    return FocusWrapper(
      focusNode: focusNode,
      onDirectionalKey: onDirectionalKey,
      onTap: onPressed,
      builder: (_, hasFocus, _) =>
          PlayerFocusDecoration(hasFocus: hasFocus, child: child),
    );
  }
}

/// A [PlayerButton] showing an icon next to a caption.
class PlayerLabeledButton extends StatelessWidget {
  const PlayerLabeledButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.focusNode,
    this.onDirectionalKey,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  /// See [FocusWrapper.onDirectionalKey].
  final KeyEventResult Function(KeyEvent event)? onDirectionalKey;

  @override
  Widget build(BuildContext context) {
    return PlayerButton(
      focusNode: focusNode,
      onDirectionalKey: onDirectionalKey,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon), const SizedBox(width: 8), Text(title)],
        ),
      ),
    );
  }
}
