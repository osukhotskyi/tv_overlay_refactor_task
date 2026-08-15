import 'package:flutter/widgets.dart';

import '../../domain/entities/device_info.dart';

/// Loads [DeviceInfo] once and shows the screen that matches the outcome.
///
/// Every outcome is passed in explicitly, so this widget only decides *which*
/// case applies and never what it looks like. The loader is injected too,
/// which keeps the widget testable without the platform channel.
class DeviceGate extends StatefulWidget {
  const DeviceGate({
    required this.load,
    required this.loading,
    required this.unsupported,
    required this.builder,
    this.failure,
    super.key,
  });

  /// Called exactly once, when the gate is first built.
  final Future<DeviceInfo> Function() load;

  /// Device info is not available yet.
  final Widget loading;

  /// The device is not an Android TV.
  final Widget unsupported;

  /// Device info could not be read at all.
  ///
  /// Defaults to [unsupported]: without a definitive answer the device cannot
  /// be treated as supported.
  final Widget? failure;

  /// The device is an Android TV. Receives the loaded info.
  final Widget Function(BuildContext context, DeviceInfo info) builder;

  @override
  State<DeviceGate> createState() => _DeviceGateState();
}

class _DeviceGateState extends State<DeviceGate> {
  // Created in a field rather than in build(), so a rebuild does not restart
  // the platform call.
  late final Future<DeviceInfo> _deviceInfo = widget.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeviceInfo>(
      future: _deviceInfo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.failure ?? widget.unsupported;
        }

        final info = snapshot.data;
        if (info == null) {
          return widget.loading;
        }

        return info.isTv ? widget.builder(context, info) : widget.unsupported;
      },
    );
  }
}
