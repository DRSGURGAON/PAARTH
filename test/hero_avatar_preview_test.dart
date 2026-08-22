import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/features/player/hero_avatar_preview.dart';
import 'package:super_kid_adventure/game/data/hero_customization_catalog.dart';
import 'package:super_kid_adventure/game/data/shop_catalog.dart';
import 'package:super_kid_adventure/game/models/hero_profile.dart';

void main() {
  /// A regression check for the bug this screen used to have: resolving
  /// a profile's option id only against the free `HeroCustomizationCatalog`
  /// list meant an equipped *shop* item silently rendered as whatever the
  /// first free option happened to be, instead of its own real color.
  testWidgets('a hero profile referencing a purchased shop color renders '
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

    final containerColors = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.decoration is BoxDecoration)
        .map((c) => (c.decoration as BoxDecoration).color)
        .toList();

    // The hair swatch is built last (see HeroAvatarPreview's Stack order:
    // backpack, 2 shoes, body, head, hair), so it's the final Container.
    // Comparing only this one avoids false negatives from other slots'
    // free-default colors coincidentally matching the buggy fallback.
    expect(containerColors.last, shopHair.color);
  });
}
