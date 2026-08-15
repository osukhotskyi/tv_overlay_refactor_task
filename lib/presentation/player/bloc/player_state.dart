part of 'player_bloc.dart';

class PlayerState extends Equatable {
  const PlayerState({
    required this.contentName,
    this.controller,
    this.value,
  });

  final PlayerController? controller;
  final PlayerValue? value;
  final String contentName;

  PlayerState copyWith({
    PlayerController? controller,
    PlayerValue? value,
    String? contentName,
  }) {
    return PlayerState(
      controller: controller ?? this.controller,
      value: value ?? this.value,
      contentName: contentName ?? this.contentName,
    );
  }

  @override
  List<Object?> get props => [controller, value, contentName];
}
