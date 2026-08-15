import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/presentation/tv_overlay/cubit/overlay_visibility_cubit.dart';

void main() {
  // The production delay; these tests assert the real behaviour, not a
  // shortened stand-in.
  const hideDelay = Duration(seconds: 5);

  test('is visible when the player opens', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => false);

      expect(cubit.state, isTrue);

      cubit.close();
      async.flushTimers();
    });
  });

  test('hides after five seconds of playback', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => true);

      async.elapse(hideDelay - const Duration(milliseconds: 1));
      expect(cubit.state, isTrue, reason: 'still within the delay');

      async.elapse(const Duration(milliseconds: 1));
      expect(cubit.state, isFalse);

      cubit.close();
    });
  });

  test('stays visible while paused', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => false);

      async.elapse(hideDelay * 3);
      expect(cubit.state, isTrue);

      cubit.close();
    });
  });

  test('reads playback state when the countdown fires, not once up front', () {
    fakeAsync((async) {
      var playing = false;
      final cubit = OverlayVisibilityCubit(isPlaying: () => playing);

      async.elapse(hideDelay);
      expect(cubit.state, isTrue, reason: 'paused, so the controls stay up');

      // Playback starts; nobody tells the cubit about it.
      playing = true;
      cubit.notifyUserActivity();
      async.elapse(hideDelay);

      expect(cubit.state, isFalse);

      cubit.close();
    });
  });

  test('user activity postpones hiding', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => true);

      async.elapse(const Duration(seconds: 4));
      cubit.notifyUserActivity();

      // Four seconds after the original countdown would have fired.
      async.elapse(const Duration(seconds: 4));
      expect(cubit.state, isTrue, reason: 'countdown restarted on activity');

      async.elapse(const Duration(seconds: 1));
      expect(cubit.state, isFalse);

      cubit.close();
    });
  });

  test('user activity brings a hidden overlay back', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => true);

      async.elapse(hideDelay);
      expect(cubit.state, isFalse);

      cubit.notifyUserActivity();
      expect(cubit.state, isTrue);

      cubit.close();
    });
  });

  test('emits visibility changes exactly once per transition', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => true);
      final emitted = <bool>[];
      final subscription = cubit.stream.listen(emitted.add);

      // Repeated activity while already visible must not spam rebuilds.
      cubit
        ..notifyUserActivity()
        ..notifyUserActivity();
      async.elapse(hideDelay);

      expect(emitted, [false]);

      subscription.cancel();
      cubit.close();
    });
  });

  test('does not hide after being closed', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => true);

      cubit.close();
      // Would throw "Cannot emit new states after calling close" if the
      // pending timer survived the cubit.
      async.elapse(hideDelay * 2);
    });
  });

  test('activity after close is a no-op, not a StateError', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => true);
      async.elapse(hideDelay);
      expect(cubit.state, isFalse);

      cubit.close();
      // A dialog callback can fire after the player subtree is gone; the
      // unguarded version would emit(true) on the closed cubit and throw.
      cubit.notifyUserActivity();

      expect(cubit.state, isFalse);
    });
  });

  test('activity after close does not schedule a new timer', () {
    fakeAsync((async) {
      final cubit = OverlayVisibilityCubit(isPlaying: () => true)..close();

      cubit.notifyUserActivity();
      // The unguarded version rescheduled: five seconds later the timer
      // would emit on the closed cubit and throw from the timer zone.
      async.elapse(hideDelay * 2);

      expect(cubit.state, isTrue);
    });
  });
}
