import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('ProgressRepository', () {
    test('stars defaults to 0 when nothing is saved', () {
      final repository = ProgressRepository(FakeLocalStorageService());

      expect(repository.stars, 0);
    });

    test('addStars() accumulates across calls', () async {
      final repository = ProgressRepository(FakeLocalStorageService());

      await repository.addStars(2);
      await repository.addStars(3);

      expect(repository.stars, 5);
    });

    test('addStars() ignores non-positive amounts', () async {
      final repository = ProgressRepository(FakeLocalStorageService());

      await repository.addStars(4);
      await repository.addStars(0);
      await repository.addStars(-1);

      expect(repository.stars, 4);
    });
  });
}
