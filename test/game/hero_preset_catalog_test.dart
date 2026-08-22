import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/data/accessory_catalog.dart';
import 'package:super_kid_adventure/game/data/hero_customization_catalog.dart';
import 'package:super_kid_adventure/game/data/hero_preset_catalog.dart';

/// Content sanity checks for the first-run preset carousel (Phase 2
/// redesign brief section 1): every preset must be a fully-formed,
/// renderable [HeroProfile] and the set as a whole must actually offer
/// the variety the brief asks for.
void main() {
  group('HeroPresetCatalog', () {
    test('offers at least a handful of presets', () {
      expect(HeroPresetCatalog.presets.length, greaterThanOrEqualTo(4));
    });

    test('every preset option id resolves to a real catalog entry', () {
      final skinToneIds =
          HeroCustomizationCatalog.skinToneOptions.map((o) => o.id).toSet();
      final hairIds = HeroCustomizationCatalog.hairOptions.map((o) => o.id).toSet();
      final outfitIds =
          HeroCustomizationCatalog.outfitOptions.map((o) => o.id).toSet();
      final shoesIds =
          HeroCustomizationCatalog.shoesOptions.map((o) => o.id).toSet();
      final backpackIds =
          HeroCustomizationCatalog.backpackOptions.map((o) => o.id).toSet();
      final accessoryIds = AccessoryCatalog.options.map((o) => o.id).toSet();

      for (final preset in HeroPresetCatalog.presets) {
        expect(skinToneIds, contains(preset.skinToneId));
        expect(hairIds, contains(preset.hairOptionId));
        expect(outfitIds, contains(preset.outfitOptionId));
        expect(shoesIds, contains(preset.shoesOptionId));
        expect(backpackIds, contains(preset.backpackOptionId));
        expect(accessoryIds, contains(preset.accessoryId));
      }
    });

    test('spans every skin tone', () {
      final usedSkinTones = HeroPresetCatalog.presets.map((p) => p.skinToneId).toSet();
      final allSkinTones =
          HeroCustomizationCatalog.skinToneOptions.map((o) => o.id).toSet();

      expect(usedSkinTones, allSkinTones);
    });

    test('includes presets both with and without an accessory', () {
      expect(
        HeroPresetCatalog.presets.any((p) => p.accessoryId == 'none'),
        isTrue,
      );
      expect(
        HeroPresetCatalog.presets.any((p) => p.accessoryId != 'none'),
        isTrue,
      );
    });
  });
}
