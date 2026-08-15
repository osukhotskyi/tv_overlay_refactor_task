import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/player_value.dart';
import '../../../domain/entities/video_source.dart';
import '../../../domain/services/playback_service.dart';

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
      super(PlayerState(contentName: source.title)) {
    on<PlayerStarted>(_onStarted);
    on<PlayerValueChanged>(_onValueChanged);
    on<PlayerPlayPauseToggled>(_onPlayPauseToggled);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerSeekedBy>(_onSeekedBy);

    _changes = _playback.changes.listen(
      (value) => add(PlayerValueChanged(value)),
    );
  }

  final PlaybackService _playback;
  late final StreamSubscription<PlayerValue> _changes;

  Future<void> _onStarted(
    PlayerStarted event,
    Emitter<PlayerState> emit,
  ) async {
    await _playback.initialize();
    await _playback.play();
    emit(state.copyWith(value: _playback.value));
  }

  void _onValueChanged(PlayerValueChanged event, Emitter<PlayerState> emit) {
    emit(state.copyWith(value: event.value));
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

  @override
  Future<void> close() async {
    await _changes.cancel();
    await super.close();
  }
}
