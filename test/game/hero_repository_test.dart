import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/data/hero_customization_catalog.dart';
import 'package:super_kid_adventure/game/models/hero_profile.dart';
import 'package:super_kid_adventure/game/repositories/hero_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('HeroRepository', () {
    test('load() returns the default profile when nothing is saved', () {
      final repository = HeroRepository(FakeLocalStorageService());

      final profile = repository.load();

      expect(profile.hairOptionId, HeroCustomizationCatalog.hairOptions.first.id);
      expect(
          profile.outfitOptionId, HeroCustomizationCatalog.outfitOptions.first.id);
    });

    test('save() then load() round-trips the chosen options', () async {
      final repository = HeroRepository(FakeLocalStorageService());
      final saved = HeroProfile(
        hairOptionId: HeroCustomizationCatalog.hairOptions[2].id,
        outfitOptionId: HeroCustomizationCatalog.outfitOptions[1].id,
        shoesOptionId: HeroCustomizationCatalog.shoesOptions[3].id,
        backpackOptionId: HeroCustomizationCatalog.backpackOptions[0].id,
      );

      await repository.save(saved);
      final loaded = repository.load();

      expect(loaded.hairOptionId, saved.hairOptionId);
      expect(loaded.outfitOptionId, saved.outfitOptionId);
      expect(loaded.shoesOptionId, saved.shoesOptionId);
      expect(loaded.backpackOptionId, saved.backpackOptionId);
    });

    test('load() falls back to defaults on corrupted save data', () async {
      final storage = FakeLocalStorageService();
      await storage.setString('hero_profile_v1', 'not valid json {');
      final repository = HeroRepository(storage);

      final profile = repository.load();

      expect(profile.hairOptionId, HeroCustomizationCatalog.hairOptions.first.id);
    });

    test('hasSavedProfile is false until a hero is actually saved',
        () async {
      final repository = HeroRepository(FakeLocalStorageService());
      expect(repository.hasSavedProfile, isFalse);

      // load() alone must not count as "saved" — it only returns a
      // usable default, it never writes anything back.
      repository.load();
      expect(repository.hasSavedProfile, isFalse);

      await repository.save(HeroProfile.initial());
      expect(repository.hasSavedProfile, isTrue);
    });
  });
}
