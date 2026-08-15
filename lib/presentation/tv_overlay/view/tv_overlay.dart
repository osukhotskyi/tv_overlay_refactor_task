import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/player_value.dart';
import '../../common/player_button.dart';
import '../../player/bloc/player_bloc.dart';
import '../cubit/overlay_visibility_cubit.dart';
import '../focus/overlay_focus_controller.dart';
import '../widgets/tv_bottom_overlay.dart';

/// The intro runs between these marks; `Skip intro` jumps to its end.
const _introStart = Duration(seconds: 10);
const _introEnd = Duration(seconds: 20);

/// How long the panels take to slide in and out.
const _panelAnimation = Duration(milliseconds: 200);

class TvOverlay extends StatefulWidget {
  const TvOverlay({super.key});

  @override
  State<TvOverlay> createState() => _TvOverlayState();
}

class _TvOverlayState extends State<TvOverlay> {
  late final PlayerBloc _bloc = context.read<PlayerBloc>();
  late final OverlayVisibilityCubit _overlay = context
      .read<OverlayVisibilityCubit>();

  late final OverlayFocusController _focus = OverlayFocusController(
    isSkipIntroVisible: () => _showSkipIntro,
    isOverlayVisible: () => _overlay.state,
    isPlaying: () => _value.isPlaying,
    onSeekBy: (offset) => _bloc.add(PlayerSeekedBy(offset)),
    onBack: () => Navigator.of(context).maybePop(),
  );

  PlayerValue get _value => _bloc.state.value;

  @override
  void initState() {
    super.initState();
    // Registered globally rather than on a Focus ancestor: a focused button
    // reports Select as handled, so the event never reaches an ancestor and
    // pressing play/pause would not restart the hide countdown.
    HardwareKeyboard.instance.addHandler(_onAnyKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.focusPlayPause();
    });
  }

  bool _onAnyKey(KeyEvent event) {
    if (event is KeyDownEvent && !_overlay.isClosed) {
      _overlay.notifyUserActivity();
    }
    return false; // Never consume: this only observes.
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onAnyKey);
    _focus.dispose();
    super.dispose();
  }

  void _focusSkipIntroIfVisible() {
    if (_value.isPlaying && _showSkipIntro) {
      _focus.skipIntro.requestFocus();
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
            if (!_overlay.state) _focusSkipIntroIfVisible();
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Scrim(visible: visible),
              _TopBar(visible: visible, backNode: _focus.back),
              _Controls(visible: visible, focus: _focus),
              _SkipIntroButton(
                visible: visible,
                node: _focus.skipIntro,
                isOnScreen: () => _showSkipIntro,
                onTap: () => _bloc.add(const PlayerSeeked(_introEnd)),
              ),
              const _BufferingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  bool get _showSkipIntro {
    final duration = _value.duration;
    return _value.initialized &&
        // The old code checked `sliderValue != 0` for this, which only
        // happened to mean "the duration is known".
        duration != null &&
        duration > Duration.zero &&
        _value.position >= _introStart &&
        _value.position < _introEnd;
  }
}

/// Dims the video while the controls are up, and whenever playback is paused.
class _Scrim extends StatelessWidget {
  const _Scrim({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (previous, current) =>
          previous.value.isPlaying != current.value.isPlaying,
      builder: (context, state) => Visibility(
        visible: visible || !state.value.isPlaying,
        child: const ColoredBox(color: Color(0x66000000)),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.visible, required this.backNode});

  final bool visible;
  final FocusNode backNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (previous, current) =>
          previous.value.isPlaying != current.value.isPlaying ||
          previous.contentName != current.contentName,
      builder: (context, state) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        child: AnimatedSlide(
          duration: _panelAnimation,
          // One full height up, so the bar clears the top edge whatever it
          // ends up measuring. No hand-tuned offset to explain.
          offset: visible || !state.value.isPlaying
              ? Offset.zero
              : const Offset(0, -1),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            child: Row(
              children: [
                PlayerButton(
                  focusNode: backNode,
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
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.visible, required this.focus});

  final bool visible;
  final OverlayFocusController focus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (previous, current) =>
          previous.value.isPlaying != current.value.isPlaying,
      builder: (context, state) => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: AnimatedSlide(
          duration: _panelAnimation,
          // One full height down: the panel is off the bottom edge no matter
          // how tall the controls turn out to be.
          offset: visible || !state.value.isPlaying
              ? Offset.zero
              : const Offset(0, 1),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
            child: TvBottomOverlay(focus: focus),
          ),
        ),
      ),
    );
  }
}

class _SkipIntroButton extends StatelessWidget {
  const _SkipIntroButton({
    required this.visible,
    required this.node,
    required this.isOnScreen,
    required this.onTap,
  });

  final bool visible;
  final FocusNode node;
  final ValueGetter<bool> isOnScreen;
  final VoidCallback onTap;

  /// High enough to clear the controls panel while it is on screen.
  static const _aboveControls = 140.0;

  /// Once the controls slide away, the button drops near the bottom edge.
  static const _nearBottomEdge = 50.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (previous, current) =>
          previous.value.position != current.value.position,
      builder: (context, state) => Visibility(
        visible: isOnScreen(),
        child: Positioned(
          left: 32,
          bottom: visible ? _aboveControls : _nearBottomEdge,
          child: PlayerLabeledButton(
            focusNode: node,
            title: 'Skip intro',
            icon: Icons.skip_next,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _BufferingIndicator extends StatelessWidget {
  const _BufferingIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (previous, current) =>
          previous.value.initialized != current.value.initialized ||
          previous.value.isLoading != current.value.isLoading,
      builder: (context, state) => Visibility(
        visible: !state.value.initialized || state.value.isLoading,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
