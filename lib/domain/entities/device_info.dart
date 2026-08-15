/// Describes the device the app is running on.
///
/// [isTv] gates the whole app: the UI is designed for a D-pad remote.
/// [isEmulator] selects the video rendering path, which has to differ on
/// emulators (see media-kit#1343).
typedef DeviceInfo = ({bool isTv, bool isEmulator});
