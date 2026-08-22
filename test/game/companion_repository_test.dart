import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('CompanionRepository', () {
    test('selectedCompanionId is null when nothing is saved', () {
      final repository = CompanionRepository(FakeLocalStorageService());

      expect(repository.selectedCompanionId, isNull);
    });

    test('selectCompanion() saves and overwrites the equipped companion',
        () async {
      final repository = CompanionRepository(FakeLocalStorageService());

      await repository.selectCompanion('robot');
      expect(repository.selectedCompanionId, 'robot');

      await repository.selectCompanion('panda');
      expect(repository.selectedCompanionId, 'panda');
    });

    test('persists across repository instances', () async {
      final storage = FakeLocalStorageService();
      await CompanionRepository(storage).selectCompanion('fox');

      final fresh = CompanionRepository(storage);
      expect(fresh.selectedCompanionId, 'fox');
    });
  });
}
