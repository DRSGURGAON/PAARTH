import 'package:flutter/material.dart';

import '../../game/data/accessory_catalog.dart';
import '../../game/data/hero_customization_catalog.dart';
import '../../game/data/shop_catalog.dart';
import '../../game/models/accessory_option.dart';
import '../../game/models/customization_option.dart';
import '../../game/models/hero_profile.dart';
import '../../game/models/shop_item.dart';

/// Renders a [HeroProfile] as a simple layered "paper doll" — no
/// production art yet (see README's Assets section), but every
/// customization choice is visibly reflected, which is what the picker
/// screen needs to feel real rather than cosmetic-only.
class HeroAvatarPreview extends StatelessWidget {
  const HeroAvatarPreview({required this.profile, this.size = 220, super.key});

  final HeroProfile profile;
  final double size;

  /// Resolves a chosen option id to its color, checking the free
  /// starter [options] first and then [ShopCatalog] — a hero profile
  /// can reference a purchased shop item id that never appears in the
  /// free catalog, so both have to be searched to render correctly.
  Color _colorFor(List<CustomizationOption> options, ShopCategory shopCategory,
      String id) {
    for (final option in options) {
      if (option.id == id) return option.color;
    }
    for (final item in ShopCatalog.itemsFor(shopCategory)) {
      if (item.id == id) return item.color;
    }
    return options.first.color;
  }

  AccessoryOption _accessoryFor(String id) {
    for (final option in AccessoryCatalog.options) {
      if (option.id == id) return option;
    }
    return AccessoryCatalog.options.first;
  }

  /// Skin tones are never sold in the Shop (section 1 asks for a real
  /// range of free choices, not a purchasable cosmetic), so this only
  /// ever needs to search the free catalog.
  Color _skinToneColorFor(String id) {
    for (final option in HeroCustomizationCatalog.skinToneOptions) {
      if (option.id == id) return option.color;
    }
    return HeroCustomizationCatalog.skinToneOptions.first.color;
  }

  @override
  Widget build(BuildContext context) {
    final skinTone = _skinToneColorFor(profile.skinToneId);
    final hairColor = _colorFor(
        HeroCustomizationCatalog.hairOptions, ShopCategory.hair, profile.hairOptionId);
    final outfitColor = _colorFor(HeroCustomizationCatalog.outfitOptions,
        ShopCategory.outfit, profile.outfitOptionId);
    final shoesColor = _colorFor(HeroCustomizationCatalog.shoesOptions,
        ShopCategory.shoes, profile.shoesOptionId);
    final backpackColor = _colorFor(HeroCustomizationCatalog.backpackOptions,
        ShopCategory.backpack, profile.backpackOptionId);
    final accessory = _accessoryFor(profile.accessoryId);

    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Backpack, peeking out behind the body.
          Positioned(
            bottom: size * 0.28,
            right: size * 0.06,
            child: Container(
              width: size * 0.32,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: backpackColor,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Shoes.
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shoe(shoesColor, size),
                SizedBox(width: size * 0.08),
                _shoe(shoesColor, size),
              ],
            ),
          ),
          // Body / outfit.
          Positioned(
            bottom: size * 0.16,
            child: Container(
              width: size * 0.5,
              height: size * 0.42,
              decoration: BoxDecoration(
                color: outfitColor,
                borderRadius: BorderRadius.circular(size * 0.14),
              ),
            ),
          ),
          // Head.
          Positioned(
            bottom: size * 0.52,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: skinTone,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Hair.
          Positioned(
            bottom: size * 0.72,
            child: Container(
              width: size * 0.44,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: hairColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.22),
                  topRight: Radius.circular(size * 0.22),
                ),
              ),
            ),
          ),
          // Accessory — an emoji badge only, not a colored Container, so
          // it never shows up over the customization-color regression
          // check that inspects the last decorated Container (the hair).
          if (accessory.emoji != null)
            Positioned(
              bottom: size * 0.66,
              right: size * 0.14,
              child: Text(
                accessory.emoji!,
                semanticsLabel: accessory.label,
                style: TextStyle(fontSize: size * 0.2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shoe(Color color, double size) {
    return Container(
      width: size * 0.16,
      height: size * 0.1,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.05),
      ),
    );
  }
}
