import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/video_source.dart';
import '../../../services/playback/player_controller.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required VideoSource source, required bool isEmulator})
    : controller = PlayerController(source.url, isEmulator: isEmulator),
      super(PlayerState(contentName: source.title)) {
    on<PlayerStarted>(_onStarted);
    on<PlayerValueChanged>(_onValueChanged);
    controller.addListener(_notifyValueChanged);
  }

  final PlayerController controller;

  Future<void> _onStarted(
    PlayerStarted event,
    Emitter<PlayerState> emit,
  ) async {
    await controller.initialize();
    await controller.play();
    emit(
      state.copyWith(
        controller: controller,
        value: controller.value,
      ),
    );
  }

  void _notifyValueChanged() => add(const PlayerValueChanged());

  void _onValueChanged(PlayerValueChanged event, Emitter<PlayerState> emit) {
    emit(state.copyWith(controller: controller, value: controller.value));
  }

  @override
  Future<void> close() async {
    controller.removeListener(_notifyValueChanged);
    controller.dispose();
    return super.close();
  }
}
