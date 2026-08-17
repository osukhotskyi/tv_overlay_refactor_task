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

/// The app went to the background; nothing may keep sounding there.
final class PlayerBackgrounded extends PlayerEvent {
  const PlayerBackgrounded();
}

/// The app is visible again. Deliberately does not resume a viewing pause —
/// only a start deferred by backgrounding fires now.
final class PlayerForegrounded extends PlayerEvent {
  const PlayerForegrounded();
}
