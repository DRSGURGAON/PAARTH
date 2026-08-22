import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/utils/duration_formatter.dart';

void main() {
  group('DurationFormatter.playTime', () {
    test('under a minute', () {
      expect(
        DurationFormatter.playTime(const Duration(seconds: 40)),
        'Less than a minute played',
      );
    });

    test('minutes only', () {
      expect(
        DurationFormatter.playTime(const Duration(minutes: 45)),
        '45 min played',
      );
    });

    test('exact hours, no leftover minutes', () {
      expect(
        DurationFormatter.playTime(const Duration(hours: 2)),
        '2h played',
      );
    });

    test('hours and minutes', () {
      expect(
        DurationFormatter.playTime(const Duration(hours: 1, minutes: 5)),
        '1h 5m played',
      );
    });

    test('rounds down partial minutes', () {
      expect(
        DurationFormatter.playTime(const Duration(minutes: 3, seconds: 59)),
        '3 min played',
      );
    });
  });
}
