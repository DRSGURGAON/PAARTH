import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/play_time_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('PlayTimeRepository', () {
    test('totalSeconds defaults to 0 when nothing is saved', () {
      final repository = PlayTimeRepository(FakeLocalStorageService());

      expect(repository.totalSeconds, 0);
    });

    test('addSeconds() accumulates across calls', () async {
      final repository = PlayTimeRepository(FakeLocalStorageService());

      await repository.addSeconds(30);
      await repository.addSeconds(45);

      expect(repository.totalSeconds, 75);
    });

    test('addSeconds() ignores non-positive amounts', () async {
      final repository = PlayTimeRepository(FakeLocalStorageService());

      await repository.addSeconds(20);
      await repository.addSeconds(0);
      await repository.addSeconds(-5);

      expect(repository.totalSeconds, 20);
    });

    test('persists across repository instances', () async {
      final storage = FakeLocalStorageService();
      await PlayTimeRepository(storage).addSeconds(60);

      final fresh = PlayTimeRepository(storage);
      expect(fresh.totalSeconds, 60);
    });
  });
}
