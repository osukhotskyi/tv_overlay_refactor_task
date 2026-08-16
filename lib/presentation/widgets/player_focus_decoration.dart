import 'package:flutter/material.dart';

/// The focus highlight shared by every control on the player screen.
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
