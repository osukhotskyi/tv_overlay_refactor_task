// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/player_value.dart';
import '../../common/widgets.dart';
import '../../player/bloc/player_bloc.dart';
import '../cubit/overlay_visibility_cubit.dart';
import '../widgets/tv_bottom_overlay.dart';

/// How far a left/right press on the progress bar jumps.
const _seekStep = Duration(seconds: 15);
const _seekStepBack = Duration(seconds: -15);

/// The intro runs between these marks; `Skip intro` jumps to its end.
const _introStart = Duration(seconds: 10);
const _introEnd = Duration(seconds: 20);

class TvOverlayOld extends StatefulWidget {
  const TvOverlayOld({super.key});

  @override
  State<TvOverlayOld> createState() => _TvOverlayOldState();
}

class _TvOverlayOldState extends State<TvOverlayOld> {
  late PlayerBloc bloc = context.read<PlayerBloc>();
  late OverlayVisibilityCubit overlay = context.read<OverlayVisibilityCubit>();
  DateTime? _lastKeyEvent;

  static const _keyEventDebounce = Duration(milliseconds: 50);

  PlayerValue get _value => bloc.state.value;

  late final _skipFocusNode = FocusNode(
    debugLabel: 'skip_focus_scope_node',
    onKeyEvent: _skipEvent,
  );

  KeyEventResult _skipEvent(FocusNode node, KeyEvent key) {
    if (key.up) {
      _backButtonFocusNode.requestFocus();
      setState(() {});
    }
    return KeyEventResult.ignored;
  }

  late final _backButtonFocusNode = FocusNode(
    debugLabel: 'back_focus_scope_node',
    onKeyEvent: (node, key) {
      setState(() {});
      if (!overlay.state && _value.isPlaying) {
        return KeyEventResult.ignored;
      }
      if (key.down) {
        _showSkipIntro ? _skipFocusNode.requestFocus() : _focusPlayPause();
        return KeyEventResult.handled;
      }
      if (key.hasSubmitIntent) {
        Navigator.of(context).maybePop();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    },
  );

  late final _actionsFocusNode = ScrollViewFocusScopeNode(
    enableAnimation: ValueNotifier(false),
    debugLabel: 'actions_focus_scope_node',
    onReached: _actionListener,
  );

  void _focusPlayPause() {
    _actionsFocusNode.children
        .where((node) => node.debugLabel == 'action')
        .firstOrNull
        ?.requestFocus();
  }

  void _actionListener(AxisDirection axis) {
    if (axis == AxisDirection.up) {
      _showSkipIntro
          ? _skipFocusNode.requestFocus()
          : _backButtonFocusNode.requestFocus();
    }
    if (axis == AxisDirection.down) {
      _progressFocusNode.requestFocus();
    }
    setState(() {});
  }

  late final _progressFocusNode = FocusScopeNode(
    debugLabel: 'progress_focus_scope_node',
    onKeyEvent: (node, event) {
      if (event is! KeyDownEvent) {
        return KeyEventResult.ignored;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        overlay.notifyUserActivity();
        // The service clamps at zero, so no special case near the start.
        bloc.add(const PlayerSeekedBy(_seekStepBack));
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        overlay.notifyUserActivity();
        bloc.add(const PlayerSeekedBy(_seekStep));
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _focusPlayPause();
        setState(() {});
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );

  bool _shouldProcessKeyEvent() {
    final now = DateTime.now();
    if (_lastKeyEvent == null) {
      _lastKeyEvent = now;
      return true;
    }
    final shouldProcess = now.difference(_lastKeyEvent!) >= _keyEventDebounce;
    if (shouldProcess) _lastKeyEvent = now;
    return shouldProcess;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusPlayPause();
    });
  }

  @override
  void dispose() {
    _skipFocusNode.dispose();
    _backButtonFocusNode.dispose();
    _actionsFocusNode.dispose();
    _progressFocusNode.dispose();
    super.dispose();
  }

  void _focusSkipIntroIfVisible() {
    if (_value.isPlaying && _showSkipIntro) {
      _skipFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Playback reaches the intro while the overlay is already hidden.
        BlocListener<PlayerBloc, PlayerState>(
          listenWhen: (previous, current) =>
              previous.value.position != current.value.position,
          listener: (context, state) {
            if (!overlay.state) _focusSkipIntroIfVisible();
          },
        ),
        // The overlay hides while the intro button is on screen. Replaces the
        // old onOverlayHided callback the video controller used to hold.
        BlocListener<OverlayVisibilityCubit, bool>(
          listenWhen: (wasVisible, isVisible) => wasVisible && !isVisible,
          listener: (context, _) => _focusSkipIntroIfVisible(),
        ),
      ],
      child: BlocBuilder<OverlayVisibilityCubit, bool>(
        builder: (context, visible) => FocusScope(
          onKeyEvent: (node, event) {
            if (!_shouldProcessKeyEvent()) {
              return KeyEventResult.ignored;
            }

            // TODO(refactor): Select on a focused button never reaches this
            // handler, because the button reports the key as handled. So
            // toggling play/pause does not restart the countdown, which the
            // task description requires. Fixed when key handling moves to
            // Shortcuts/Actions and every action funnels through one place.
            overlay.notifyUserActivity();
            return KeyEventResult.ignored;
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (previous, current) =>
                    previous.value.isPlaying != current.value.isPlaying,
                builder: (context, state) => Visibility(
                  visible: visible || !state.value.isPlaying,
                  child: const ColoredBox(color: Color(0x66000000)),
                ),
              ),
              BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (previous, current) =>
                    previous.value.isPlaying != current.value.isPlaying ||
                    previous.contentName != current.contentName,
                builder: (context, state) => AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: 32,
                  right: 32,
                  top: visible || !state.value.isPlaying ? 32 : -80,
                  child: Row(
                    children: [
                      PlayerButton(
                        focusNode: _backButtonFocusNode,
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        state.contentName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (previous, current) =>
                    previous.value.isPlaying != current.value.isPlaying,
                builder: (context, state) => AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: 32,
                  right: 32,
                  bottom: visible || !state.value.isPlaying ? 24 : -140,
                  child: TvBottomOverlay(
                    nodes: [_actionsFocusNode, _progressFocusNode],
                  ),
                ),
              ),
              BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (previous, current) =>
                    previous.value.position != current.value.position,
                builder: (context, state) => Visibility(
                  visible: _showSkipIntro,
                  child: Positioned(
                    left: 32,
                    bottom: visible ? 140 : 50,
                    child: DefaultPlayerButton(
                      node: _skipFocusNode,
                      title: 'Skip intro',
                      icon: Icons.skip_next,
                      onTap: () => bloc.add(const PlayerSeeked(_introEnd)),
                    ),
                  ),
                ),
              ),
              BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (previous, current) =>
                    previous.value.initialized != current.value.initialized ||
                    previous.value.isLoading != current.value.isLoading,
                builder: (context, state) => Visibility(
                  visible: !state.value.initialized || state.value.isLoading,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _showSkipIntro =>
      _value.position >= _introStart &&
      _value.position < _introEnd &&
      _value.sliderValue != 0 &&
      _value.initialized;
}
