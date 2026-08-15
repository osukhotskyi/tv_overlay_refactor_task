import 'package:flutter/services.dart';

const _deviceChannel = MethodChannel('tv_overlay_refactor_task/device');

typedef DeviceInfo = ({bool isTv, bool isEmulator});

Future<DeviceInfo> loadDeviceInfo() async {
  final result = await _deviceChannel.invokeMapMethod<String, bool>(
    'getDeviceInfo',
  );

  return (
    isTv: result?['isTv'] ?? false,
    isEmulator: result?['isEmulator'] ?? false,
  );
}
