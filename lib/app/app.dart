import 'package:flutter/material.dart';

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
        builder: (_, info) =>
            PlayerScreen(source: sampleVideo, isEmulator: info.isEmulator),
      ),
    );
  }
}
