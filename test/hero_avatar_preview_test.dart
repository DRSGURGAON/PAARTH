import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/features/player/hero_avatar_preview.dart';
import 'package:super_kid_adventure/game/data/hero_customization_catalog.dart';
import 'package:super_kid_adventure/game/data/shop_catalog.dart';
import 'package:super_kid_adventure/game/models/hero_profile.dart';
import 'package:super_kid_adventure/game/models/shop_item.dart';

void main() {
  HeroAvatarPainter painterOf(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
        find.byKey(const ValueKey('hero_painter')));
    return paint.painter! as HeroAvatarPainter;
  }

  testWidgets('a hero profile with a chosen skin tone paints that '
      "tone's real color, not a hardcoded default", (tester) async {
    final deepestTone = HeroCustomizationCatalog.skinToneOptions.last;
    final profile = HeroProfile.initial().copyWith(skinToneId: deepestTone.id);

    await tester.pumpWidget(
      MaterialApp(home: HeroAvatarPreview(profile: profile)),
    );

    expect(painterOf(tester).skinColor, deepestTone.color);
  });

  testWidgets('an accessory renders its emoji, and "None" renders nothing',
      (tester) async {
    final withAccessory = HeroProfile.initial().copyWith(accessoryId: 'cape');
    await tester.pumpWidget(
      MaterialApp(home: HeroAvatarPreview(profile: withAccessory)),
    );
    expect(find.text('🧣'), findsOneWidget);

    final withoutAccessory = HeroProfile.initial().copyWith(accessoryId: 'none');
    await tester.pumpWidget(
      MaterialApp(home: HeroAvatarPreview(profile: withoutAccessory)),
    );
    expect(find.text('🧣'), findsNothing);
  });

  /// A regression check for the bug this widget used to have: resolving
  /// a profile's option id only against the free `HeroCustomizationCatalog`
  /// list meant an equipped *shop* item silently rendered as whatever the
  /// first free option happened to be, instead of its own real color.
  testWidgets('a hero profile referencing a purchased shop color paints '
      "that item's real color, not the first free option's",
      (tester) async {
    final shopHair = ShopCatalog.itemsFor(ShopCategory.hair).first;
    final freeFirstHair = HeroCustomizationCatalog.hairOptions.first;
    // Sanity: pick a shop swatch whose color actually differs from the
    // free default, otherwise this test couldn't tell success from the
    // old bug.
    expect(shopHair.color, isNot(freeFirstHair.color));

    final profile = HeroProfile.initial().copyWith(hairOptionId: shopHair.id);

    await tester.pumpWidget(
      MaterialApp(home: HeroAvatarPreview(profile: profile)),
    );

    expect(painterOf(tester).hairColor, shopHair.color);
  });

  testWidgets('every customization slot reaches its painted color',
      (tester) async {
    final profile = HeroProfile(
      skinToneId: HeroCustomizationCatalog.skinToneOptions[2].id,
      hairOptionId: HeroCustomizationCatalog.hairOptions[1].id,
      outfitOptionId: HeroCustomizationCatalog.outfitOptions[2].id,
      shoesOptionId: HeroCustomizationCatalog.shoesOptions[3].id,
      backpackOptionId: HeroCustomizationCatalog.backpackOptions[1].id,
      accessoryId: 'none',
    );

    await tester.pumpWidget(
      MaterialApp(home: HeroAvatarPreview(profile: profile)),
    );

    final painter = painterOf(tester);
    expect(painter.skinColor,
        HeroCustomizationCatalog.skinToneOptions[2].color);
    expect(painter.hairColor, HeroCustomizationCatalog.hairOptions[1].color);
    expect(painter.outfitColor,
        HeroCustomizationCatalog.outfitOptions[2].color);
    expect(painter.shoesColor, HeroCustomizationCatalog.shoesOptions[3].color);
    expect(painter.backpackColor,
        HeroCustomizationCatalog.backpackOptions[1].color);
  });
}
