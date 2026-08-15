import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      home: FutureBuilder<DeviceInfo>(
        // TODO(refactor): a new Future is created on every rebuild.
        // Hoisted into a field in the next step.
        future: loadDeviceInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ColoredBox(color: Colors.black);
          }

          if (snapshot.data?.isTv != true) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  'This app requires Android TV',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            );
          }

          return BlocProvider(
            create: (_) =>
                PlayerBloc(isEmulator: snapshot.data!.isEmulator)
                  ..add(const PlayerStarted()),
            child: const PlayerScreen(),
          );
        },
      ),
    );
  }
}
