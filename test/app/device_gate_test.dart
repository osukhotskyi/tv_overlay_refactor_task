import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/domain/entities/device_info.dart';
import 'package:tv_overlay_refactor_task/app/device_gate.dart';

void main() {
  const tv = (isTv: true, isEmulator: false);
  const tvEmulator = (isTv: true, isEmulator: true);
  const phone = (isTv: false, isEmulator: false);

  Widget buildGate({
    required Future<DeviceInfo> Function() load,
    Widget? failure,
  }) {
    return MaterialApp(
      home: DeviceGate(
        load: load,
        loading: const Text('loading'),
        unsupported: const Text('unsupported'),
        failure: failure,
        builder: (_, info) => Text('player isEmulator=${info.isEmulator}'),
      ),
    );
  }

  testWidgets('shows the loading screen until device info arrives', (
    tester,
  ) async {
    final completer = Completer<DeviceInfo>();
    await tester.pumpWidget(buildGate(load: () => completer.future));

    expect(find.text('loading'), findsOneWidget);

    completer.complete(tv);
    await tester.pump();

    expect(find.text('loading'), findsNothing);
  });

  testWidgets('builds the player on a TV and passes the info through', (
    tester,
  ) async {
    await tester.pumpWidget(buildGate(load: () async => tvEmulator));
    await tester.pump();

    expect(find.text('player isEmulator=true'), findsOneWidget);
  });

  testWidgets('shows the unsupported screen when the device is not a TV', (
    tester,
  ) async {
    await tester.pumpWidget(buildGate(load: () async => phone));
    await tester.pump();

    expect(find.text('unsupported'), findsOneWidget);
  });

  testWidgets('falls back to the unsupported screen when the lookup fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildGate(load: () async => throw Exception('no channel')),
    );
    await tester.pump();

    // Without a definitive answer the device cannot be treated as supported.
    expect(find.text('unsupported'), findsOneWidget);
  });

  testWidgets('prefers the failure screen when one is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildGate(
        load: () async => throw Exception('no channel'),
        failure: const Text('failure'),
      ),
    );
    await tester.pump();

    expect(find.text('failure'), findsOneWidget);
    expect(find.text('unsupported'), findsNothing);
  });

  testWidgets('loads device info once, not on every rebuild', (tester) async {
    var calls = 0;
    Future<DeviceInfo> load() async {
      calls++;
      return tv;
    }

    await tester.pumpWidget(buildGate(load: load));
    await tester.pump();
    await tester.pumpWidget(buildGate(load: load));
    await tester.pump();

    expect(calls, 1);
  });
}
