import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/shop_item.dart';
import 'package:super_kid_adventure/game/repositories/room_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('RoomRepository', () {
    test('load() returns an empty profile when nothing is saved', () {
      final repository = RoomRepository(FakeLocalStorageService());
      final profile = repository.load();

      expect(profile.wallArtItemId, isNull);
      expect(profile.rugItemId, isNull);
      expect(profile.plantItemId, isNull);
      expect(profile.lampItemId, isNull);
    });

    test('setSlot() equips one slot without touching the others', () async {
      final repository = RoomRepository(FakeLocalStorageService());

      await repository.setSlot(ShopCategory.wallArt, 'wallart_stars');
      await repository.setSlot(ShopCategory.rug, 'rug_stripes');

      final profile = repository.load();
      expect(profile.wallArtItemId, 'wallart_stars');
      expect(profile.rugItemId, 'rug_stripes');
      expect(profile.plantItemId, isNull);
      expect(profile.lampItemId, isNull);
    });

    test('setSlot() with null clears that slot only', () async {
      final storage = FakeLocalStorageService();
      final repository = RoomRepository(storage);
      await repository.setSlot(ShopCategory.plant, 'plant_cactus');
      await repository.setSlot(ShopCategory.lamp, 'lamp_moon');

      await repository.setSlot(ShopCategory.plant, null);

      final profile = repository.load();
      expect(profile.plantItemId, isNull);
      expect(profile.lampItemId, 'lamp_moon');
    });

    test('persists across repository instances', () async {
      final storage = FakeLocalStorageService();
      await RoomRepository(storage).setSlot(ShopCategory.rug, 'rug_clouds');

      final fresh = RoomRepository(storage);
      expect(fresh.load().rugItemId, 'rug_clouds');
    });

    test('itemIdFor reads the right field for each room slot', () async {
      final storage = FakeLocalStorageService();
      final repository = RoomRepository(storage);
      await repository.setSlot(ShopCategory.wallArt, 'a');
      await repository.setSlot(ShopCategory.rug, 'b');
      await repository.setSlot(ShopCategory.plant, 'c');
      await repository.setSlot(ShopCategory.lamp, 'd');

      final profile = repository.load();
      expect(repository.itemIdFor(profile, ShopCategory.wallArt), 'a');
      expect(repository.itemIdFor(profile, ShopCategory.rug), 'b');
      expect(repository.itemIdFor(profile, ShopCategory.plant), 'c');
      expect(repository.itemIdFor(profile, ShopCategory.lamp), 'd');
    });

    test('setSlot() rejects hero categories — they have no room slot', () {
      final repository = RoomRepository(FakeLocalStorageService());

      expect(
        () => repository.setSlot(ShopCategory.hair, 'hair_rose'),
        throwsArgumentError,
      );
    });

    test('load() falls back to an empty profile on corrupted save data',
        () async {
      final storage = FakeLocalStorageService();
      await storage.setString('room_profile_v1', 'not valid json {');
      final repository = RoomRepository(storage);

      final profile = repository.load();

      expect(profile.wallArtItemId, isNull);
      expect(profile.rugItemId, isNull);
      expect(profile.plantItemId, isNull);
      expect(profile.lampItemId, isNull);
    });
  });
}
