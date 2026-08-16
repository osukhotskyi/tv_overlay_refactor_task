import 'package:flutter/material.dart';

class UnsupportedDeviceScreen extends StatelessWidget {
  const UnsupportedDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}
