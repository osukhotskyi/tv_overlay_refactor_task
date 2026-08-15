part of 'player_bloc.dart';

class PlayerState extends Equatable {
  const PlayerState({required this.contentName, required this.value});

  final String contentName;

  /// Never null — before the service reports anything it holds
  /// [PlayerValue.initial], which spares every widget a null check.
  final PlayerValue value;

  PlayerState copyWith({String? contentName, PlayerValue? value}) {
    return PlayerState(
      contentName: contentName ?? this.contentName,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [contentName, value];
}
