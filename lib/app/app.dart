import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/common/device_gate.dart';
import '../presentation/common/unsupported_device_screen.dart';
import '../presentation/player/bloc/player_bloc.dart';
import '../presentation/player/view/player_screen.dart';
import '../services/device/device_info_service.dart';

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
        builder: (context, info) => BlocProvider(
          create: (_) =>
              PlayerBloc(isEmulator: info.isEmulator)
                ..add(const PlayerStarted()),
          child: const PlayerScreen(),
        ),
      ),
    );
  }
}
