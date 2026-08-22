import '../models/hero_profile.dart';

/// Curated starter looks offered on first run (Phase 2 redesign brief
/// section 1): "several original fictional hero presets... different
/// hair styles, outfits, skin tones, accessories." Each preset is just a
/// fully-specified [HeroProfile] built from the same catalogs the
/// detailed Customize screen (reachable later from the Room) uses, so
/// picking one here and refining it there is the same profile the whole
/// way through — no separate preset model, no duplicated option data.
///
/// The set deliberately spans every skin tone and every accessory
/// (including none) across a mix of styling choices, rather than asking
/// the child to declare a gender up front.
class HeroPresetCatalog {
  HeroPresetCatalog._();

  static const List<HeroProfile> presets = [
    HeroProfile(
      skinToneId: 'fair',
      hairOptionId: 'sunshine',
      outfitOptionId: 'sky',
      shoesOptionId: 'sunny',
      backpackOptionId: 'ranger',
      accessoryId: 'none',
    ),
    HeroProfile(
      skinToneId: 'light',
      hairOptionId: 'berry',
      outfitOptionId: 'coral',
      shoesOptionId: 'flame',
      backpackOptionId: 'star',
      accessoryId: 'bow',
    ),
    HeroProfile(
      skinToneId: 'tan',
      hairOptionId: 'midnight',
      outfitOptionId: 'leaf',
      shoesOptionId: 'mint',
      backpackOptionId: 'explorer',
      accessoryId: 'sunglasses',
    ),
    HeroProfile(
      skinToneId: 'deep',
      hairOptionId: 'copper',
      outfitOptionId: 'grape',
      shoesOptionId: 'ocean',
      backpackOptionId: 'cosmic',
      accessoryId: 'cape',
    ),
    HeroProfile(
      skinToneId: 'deepest',
      hairOptionId: 'sunshine',
      outfitOptionId: 'coral',
      shoesOptionId: 'sunny',
      backpackOptionId: 'star',
      accessoryId: 'flower',
    ),
    HeroProfile(
      skinToneId: 'fair',
      hairOptionId: 'midnight',
      outfitOptionId: 'sky',
      shoesOptionId: 'ocean',
      backpackOptionId: 'ranger',
      accessoryId: 'sunglasses',
    ),
    HeroProfile(
      skinToneId: 'tan',
      hairOptionId: 'copper',
      outfitOptionId: 'grape',
      shoesOptionId: 'flame',
      backpackOptionId: 'cosmic',
      accessoryId: 'cape',
    ),
    HeroProfile(
      skinToneId: 'light',
      hairOptionId: 'berry',
      outfitOptionId: 'leaf',
      shoesOptionId: 'mint',
      backpackOptionId: 'explorer',
      accessoryId: 'bow',
    ),
  ];
}
