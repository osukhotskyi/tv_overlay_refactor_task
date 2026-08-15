part of 'player_bloc.dart';

class PlayerState extends Equatable {
  const PlayerState({
    required this.contentName,
    this.value = const PlayerValue(),
  });

  final String contentName;

  /// Never null: before the service reports anything this holds the defaults,
  /// which spares every widget a null check.
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
