import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/presentation/utils/duration_label.dart';

void main() {
  test('pads minutes and seconds and omits zero hours', () {
    expect(Duration.zero.asTimeLabel, '00:00');
    expect(const Duration(seconds: 5).asTimeLabel, '00:05');
    expect(const Duration(seconds: 61).asTimeLabel, '01:01');
    expect(const Duration(minutes: 59, seconds: 59).asTimeLabel, '59:59');
  });

  test('adds the hours prefix once the media is that long', () {
    expect(const Duration(hours: 1).asTimeLabel, '01:00:00');
    expect(
      const Duration(hours: 1, minutes: 2, seconds: 3).asTimeLabel,
      '01:02:03',
    );
    expect(const Duration(hours: 10, minutes: 40).asTimeLabel, '10:40:00');
  });
}
