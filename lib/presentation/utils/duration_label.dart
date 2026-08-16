/// Formats durations the way the player UI shows them: `mm:ss`, gaining an
/// hours prefix once the media is that long (`hh:mm:ss`).
///
/// Deliberately a visible, importable spot rather than a private helper in
/// whichever widget needed it first: formatting is a presentation-wide
/// concern, and a label this generic gets re-implemented the moment it is
/// hidden.
extension DurationLabel on Duration {
  String get asTimeLabel {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    final value =
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return hours == 0 ? value : '${hours.toString().padLeft(2, '0')}:$value';
  }
}
