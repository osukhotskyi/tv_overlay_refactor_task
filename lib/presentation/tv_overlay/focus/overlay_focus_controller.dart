import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Owns every focus node of the overlay and all movement between its zones.
///
/// Previously this was spread across five separate `onKeyEvent` callbacks that
/// each decided where the D-pad should go next. Keeping it together means the
/// rules can be read in one sitting — and the play/pause node is now held by
/// reference instead of being looked up by `debugLabel`, which silently fails
/// in release builds because that label is only assigned inside an assert.
class OverlayFocusController {
  OverlayFocusController({
    required this.isSkipIntroVisible,
    required this.isOverlayVisible,
    required this.isPlaying,
    required this.onSeekBy,
    required this.onBack,
    this.seekStep = const Duration(seconds: 15),
  });

  /// Asked when a key arrives, so the answer is never stale.
  final ValueGetter<bool> isSkipIntroVisible;
  final ValueGetter<bool> isOverlayVisible;
  final ValueGetter<bool> isPlaying;

  final ValueChanged<Duration> onSeekBy;
  final VoidCallback onBack;

  /// How far one left/right press on the progress bar jumps.
  final Duration seekStep;

  late final FocusNode back = FocusNode(
    debugLabel: 'overlay.back',
    onKeyEvent: _onBackKey,
  );

  /// The play/pause button. Held directly; never searched for.
  late final FocusNode playPause = FocusNode(debugLabel: 'overlay.playPause');

  late final FocusNode skipIntro = FocusNode(
    debugLabel: 'overlay.skipIntro',
    onKeyEvent: _onSkipIntroKey,
  );

  /// Wraps the row of player actions, so left/right inside it stays default.
  late final FocusScopeNode actions = FocusScopeNode(
    debugLabel: 'overlay.actions',
    onKeyEvent: _onActionsKey,
  );

  late final FocusScopeNode progress = FocusScopeNode(
    debugLabel: 'overlay.progress',
    onKeyEvent: _onProgressKey,
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

  KeyEventResult _onBackKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // While the controls are hidden the first press only brings them back.
    if (!isOverlayVisible() && isPlaying()) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      focusBelowTopBar();
      return KeyEventResult.handled;
    }
    if (_isSubmit(event)) {
      onBack();
      return KeyEventResult.handled;
    }
    // Swallow the rest so the top bar does not hand focus sideways.
    return KeyEventResult.handled;
  }

  KeyEventResult _onSkipIntroKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
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

  KeyEventResult _onProgressKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      onSeekBy(-seekStep);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      onSeekBy(seekStep);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      focusPlayPause();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  static bool _isSubmit(KeyEvent event) =>
      event.logicalKey == LogicalKeyboardKey.enter ||
      event.logicalKey == LogicalKeyboardKey.select;

  void dispose() {
    back.dispose();
    playPause.dispose();
    skipIntro.dispose();
    actions.dispose();
    progress.dispose();
  }
}
