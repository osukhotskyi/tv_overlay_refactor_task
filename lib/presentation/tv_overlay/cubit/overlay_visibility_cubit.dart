import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Whether the playback controls are currently on screen.
///
/// This is presentation state, so it lives next to the overlay instead of
/// inside the video controller. Keeping the timer here also ties its lifetime
/// to the widget tree: it is cancelled in [close] and can no longer outlive
/// the screen that started it.
class OverlayVisibilityCubit extends Cubit<bool> {
  /// The overlay is on screen when the player opens.
  OverlayVisibilityCubit({this.hideDelay = const Duration(seconds: 5)})
    : super(true) {
    _scheduleHide();
  }

  /// How long the overlay stays up without user input.
  final Duration hideDelay;

  Timer? _hideTimer;
  bool _isPlaying = false;

  /// Call on any remote key press or tap: the overlay comes back and the
  /// countdown starts over.
  void notifyUserActivity() {
    // Guarded rather than relying on Cubit's duplicate-state filter: that
    // filter lets the very first emit through even when the value is
    // unchanged, which would rebuild the overlay for nothing.
    if (!state) emit(true);
    _scheduleHide();
  }

  /// Keeps track of playback, because the overlay is never hidden while
  /// paused.
  // ignore: use_setters_to_change_properties
  void setPlaying(bool isPlaying) => _isPlaying = isPlaying;

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(hideDelay, () {
      // While paused the controls stay up; the next user action reschedules.
      if (!_isPlaying) return;
      emit(false);
    });
  }

  @override
  Future<void> close() {
    _hideTimer?.cancel();
    return super.close();
  }
}
