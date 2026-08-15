import 'package:flutter/material.dart';

import '../presentation/common/device_gate.dart';
import '../presentation/common/unsupported_device_screen.dart';
import '../presentation/player/view/player_screen.dart';
import '../services/device/device_info_service.dart';
import '../services/playback/media_kit_playback_service.dart';
import '../services/playback/media_kit_video_surface.dart';
import 'sample_content.dart';

class TvOverlayRefactorApp extends StatelessWidget {
  const TvOverlayRefactorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Overlay Refactor Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DeviceGate(
        load: loadDeviceInfo,
        loading: const ColoredBox(color: Colors.black),
        unsupported: const UnsupportedDeviceScreen(),
        // This is the only place that knows which player is in use, and the
        // only place that cares whether we are on an emulator.
        builder: (_, info) => PlayerScreen(
          source: sampleVideo,
          createPlayback: (source) {
            final service = MediaKitPlaybackService(
              source.url,
              isEmulator: info.isEmulator,
            );
            return (
              service: service,
              surface: MediaKitVideoSurface(service: service),
            );
          },
        ),
      ),
    );
  }
}
