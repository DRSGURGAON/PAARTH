import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/shop_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('ShopRepository', () {
    test('ownedItemIds is empty when nothing is saved', () {
      final repository = ShopRepository(FakeLocalStorageService());

      expect(repository.ownedItemIds(), isEmpty);
    });

    test('markOwned() records the id and is idempotent', () async {
      final repository = ShopRepository(FakeLocalStorageService());

      await repository.markOwned('hair_rose');
      await repository.markOwned('hair_rose');
      await repository.markOwned('rug_stripes');

      expect(repository.ownedItemIds(), {'hair_rose', 'rug_stripes'});
    });

    test('persists across repository instances', () async {
      final storage = FakeLocalStorageService();
      await ShopRepository(storage).markOwned('lamp_moon');

      final fresh = ShopRepository(storage);
      expect(fresh.ownedItemIds(), {'lamp_moon'});
    });
  });
}
