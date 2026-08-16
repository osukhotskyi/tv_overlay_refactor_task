import 'package:flutter/material.dart';

import '../domain/entities/video_source.dart';
import '../presentation/screens/films/films_screen.dart';
import '../presentation/screens/player/player_screen.dart';
import '../presentation/screens/unsupported_device/unsupported_device_screen.dart';
import '../services/device/device_info_service.dart';
import '../services/playback/media_kit_playback_service.dart';
import '../services/playback/media_kit_video_surface.dart';
import 'device_gate.dart';
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
        builder: (context, info) => FilmsScreen(
          films: sampleCatalogue,
          onFilmSelected: (film) =>
              _playFilm(context, film, isEmulator: info.isEmulator),
        ),
      ),
    );
  }

  // This is the only place that knows which player is in use, and the only
  // place that cares whether we are on an emulator.
  void _playFilm(
    BuildContext context,
    VideoSource film, {
    required bool isEmulator,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(
          source: film,
          createPlayback: (source) {
            final service = MediaKitPlaybackService(
              source.url,
              isEmulator: isEmulator,
            );
            return (
              service: service,
              surface: MediaKitVideoSurface(
                controller: service.videoController,
              ),
            );
          },
        ),
      ),
    );
  }
}
