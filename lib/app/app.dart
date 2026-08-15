import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/device_info.dart';
import '../presentation/common/device_gate.dart';
import '../presentation/common/unsupported_device_screen.dart';
import '../presentation/player/view/player_screen.dart';
import '../services/device/device_info_service.dart';
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
        // Device info is ambient: it describes the environment rather than
        // this screen, so it is provided once instead of being passed down.
        builder: (_, info) => RepositoryProvider<DeviceInfo>.value(
          value: info,
          child: const PlayerScreen(source: sampleVideo),
        ),
      ),
    );
  }
}
