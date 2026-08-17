import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/player_value.dart';
import '../../../../domain/entities/video_source.dart';
import '../../../../domain/services/playback_service.dart';

part 'player_event.dart';
part 'player_state.dart';

/// Turns playback commands into calls on [PlaybackService] and its reports
/// into state.
///
/// The service is injected, not created here, so tests can run without a real
/// player. Disposing it stays with whoever created it — see PlayerScreen.
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required VideoSource source, required PlaybackService playback})
    : _playback = playback,
      super(
        PlayerState(
          contentName: source.title,
          value: const PlayerValue.initial(),
        ),
      ) {
    on<PlayerStarted>(_onStarted);
    on<PlayerValueChanged>(_onValueChanged);
    on<PlayerPlayPauseToggled>(_onPlayPauseToggled);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerSeekedBy>(_onSeekedBy);
    on<PlayerBackgrounded>(_onBackgrounded);
    on<PlayerForegrounded>(_onForegrounded);

    _changes = _playback.changes.listen(
      (value) => add(PlayerValueChanged(value)),
    );
  }

  final PlaybackService _playback;
  late final StreamSubscription<PlayerValue> _changes;

  /// The background policy lives here, not in a widget: the video surface
  /// mounts only once the player is initialized, so a widget-side observer
  /// misses everything that happens during the loading window.
  bool _inBackground = false;
  bool _startDeferredByBackground = false;

  Future<void> _onStarted(
    PlayerStarted event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      await _playback.initialize();
      if (_inBackground) {
        // Home was pressed while the spinner was up. Starting now would
        // play sound behind the launcher; start when the app is back.
        _startDeferredByBackground = true;
      } else {
        await _playback.play();
      }
      emit(state.copyWith(value: _playback.value));
    } catch (error) {
      // The service only reports errors its player noticed; a throw out of
      // open/play would otherwise leave the spinner up forever.
      emit(
        state.copyWith(
          value: _playback.value.copyWith(errorDescription: '$error'),
        ),
      );
    }
  }

  void _onValueChanged(PlayerValueChanged event, Emitter<PlayerState> emit) {
    final isNewError =
        state.value.errorDescription == null &&
        event.value.errorDescription != null;
    emit(state.copyWith(value: event.value));
    if (isNewError) {
      // The error screen replaces the video surface; without this the sound
      // keeps playing behind it.
      _playback.pause();
    }
  }

  Future<void> _onPlayPauseToggled(
    PlayerPlayPauseToggled event,
    Emitter<PlayerState> emit,
  ) {
    return state.value.isPlaying ? _playback.pause() : _playback.play();
  }

  Future<void> _onSeeked(PlayerSeeked event, Emitter<PlayerState> emit) {
    return _playback.seekTo(event.position);
  }

  Future<void> _onSeekedBy(PlayerSeekedBy event, Emitter<PlayerState> emit) {
    return _playback.seekBy(event.offset);
  }

  Future<void> _onBackgrounded(
    PlayerBackgrounded event,
    Emitter<PlayerState> emit,
  ) async {
    _inBackground = true;
    if (state.value.isPlaying) await _playback.pause();
  }

  Future<void> _onForegrounded(
    PlayerForegrounded event,
    Emitter<PlayerState> emit,
  ) async {
    _inBackground = false;
    // A viewing pause stays a pause — resuming is the viewer's call. Only a
    // start that backgrounding deferred fires now.
    if (_startDeferredByBackground) {
      _startDeferredByBackground = false;
      await _playback.play();
    }
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    await super.close();
  }
}
