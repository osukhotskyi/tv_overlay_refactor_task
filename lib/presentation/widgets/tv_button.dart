import 'package:flutter/material.dart';

import 'focus_wrapper.dart';
import 'tv_focus_decoration.dart';

/// A focusable button wearing the standard highlight.
///
/// Composed from [FocusWrapper] rather than repeating its focus and key
/// handling, which is what the previous pair of near-identical button
/// widgets did.
class TvButton extends StatelessWidget {
  const TvButton({
    required this.onPressed,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onDirectionalKey,
    super.key,
  });

  final VoidCallback onPressed;
  final Widget child;
  final FocusNode? focusNode;

  /// See [FocusWrapper.autofocus].
  final bool autofocus;

  /// See [FocusWrapper.onDirectionalKey].
  final KeyEventResult Function(KeyEvent event)? onDirectionalKey;

  @override
  Widget build(BuildContext context) {
    return FocusWrapper(
      focusNode: focusNode,
      autofocus: autofocus,
      onDirectionalKey: onDirectionalKey,
      onTap: onPressed,
      builder: (_, hasFocus, _) =>
          TvFocusDecoration(hasFocus: hasFocus, child: child),
    );
  }
}

/// A [TvButton] showing an icon next to a caption.
class TvLabeledButton extends StatelessWidget {
  const TvLabeledButton({
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
    return TvButton(
      focusNode: focusNode,
      onDirectionalKey: onDirectionalKey,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [Icon(icon), Text(title)],
        ),
      ),
    );
  }
}
