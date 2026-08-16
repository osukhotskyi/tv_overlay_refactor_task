part of 'player_bloc.dart';

sealed class PlayerEvent {
  const PlayerEvent();
}

/// Open the media and start playing.
final class PlayerStarted extends PlayerEvent {
  const PlayerStarted();
}

/// The service reported new state. Internal.
final class PlayerValueChanged extends PlayerEvent {
  const PlayerValueChanged(this.value);

  final PlayerValue value;
}

final class PlayerPlayPauseToggled extends PlayerEvent {
  const PlayerPlayPauseToggled();
}

final class PlayerSeeked extends PlayerEvent {
  const PlayerSeeked(this.position);

  final Duration position;
}

/// Negative [offset] seeks backwards. The service clamps to the media bounds.
final class PlayerSeekedBy extends PlayerEvent {
  const PlayerSeekedBy(this.offset);

  final Duration offset;
}
