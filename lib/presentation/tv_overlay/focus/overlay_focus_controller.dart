import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Owns the overlay's focus nodes and answers one question: where does a
/// direction lead from here.
///
/// That answer cannot live in the individual widgets, because it depends on
/// zones they know nothing about — `up` from the action row goes to the intro
/// button when it is on screen and to the top bar otherwise. Behaviour that a
/// widget *can* decide alone stays with the widget: Select belongs to the
/// button that was pressed, seeking belongs to the progress bar.
///
/// Nodes attached to a [Focus] widget get their `onKeyEvent` overwritten on
/// attach, so the two handlers below are handed to those widgets instead of
/// being installed on the nodes.
class OverlayFocusController {
  OverlayFocusController({required this.isSkipIntroVisible});

  /// Asked when a key arrives, so the answer is never stale.
  final ValueGetter<bool> isSkipIntroVisible;

  final FocusNode back = FocusNode(debugLabel: 'overlay.back');

  /// The play/pause button. Held directly; never searched for.
  final FocusNode playPause = FocusNode(debugLabel: 'overlay.playPause');

  final FocusNode skipIntro = FocusNode(debugLabel: 'overlay.skipIntro');

  /// Wraps the row of player actions, so left/right inside it stays default.
  late final FocusScopeNode actions = FocusScopeNode(
    debugLabel: 'overlay.actions',
    onKeyEvent: _onActionsKey,
  );

  final FocusScopeNode progress = FocusScopeNode(
    debugLabel: 'overlay.progress',
  );

  void focusPlayPause() => playPause.requestFocus();

  /// Where `up` leads from the action row: the intro button when it is on
  /// screen, otherwise the top bar.
  void focusAboveActions() {
    isSkipIntroVisible() ? skipIntro.requestFocus() : back.requestFocus();
  }

  /// Where `down` leads from the top bar.
  void focusBelowTopBar() {
    isSkipIntroVisible() ? skipIntro.requestFocus() : focusPlayPause();
  }

  /// Directional keys for the back button. Pass to its `onDirectionalKey`.
  ///
  /// Only arrows are claimed — repeats included, so a held key cannot slip
  /// past into geometric traversal: down routes below, the rest die here so
  /// the top bar does not hand focus sideways. Everything else — notably the
  /// remote's system Back — is left to the platform.
  KeyEventResult onBackKey(KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      focusBelowTopBar();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Directional keys for the intro button. Pass to its `onDirectionalKey`.
  KeyEventResult onSkipIntroKey(KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      back.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onActionsKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      focusAboveActions();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      progress.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void dispose() {
    back.dispose();
    playPause.dispose();
    skipIntro.dispose();
    actions.dispose();
    progress.dispose();
  }
}
