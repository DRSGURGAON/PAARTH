import '../data/accessory_catalog.dart';
import '../data/hero_customization_catalog.dart';

/// The child's chosen hero appearance. Holds option *ids* only (never
/// [Color]s or widgets) so it stays trivially JSON-serializable for
/// local save/load, and would stay just as simple if cloud sync were
/// ever added later.
class HeroProfile {
  const HeroProfile({
    required this.skinToneId,
    required this.hairOptionId,
    required this.outfitOptionId,
    required this.shoesOptionId,
    required this.backpackOptionId,
    required this.accessoryId,
  });

  /// Default hero shown the first time a child opens the game: the first
  /// option in each category, no accessory.
  factory HeroProfile.initial() {
    return HeroProfile(
      skinToneId: HeroCustomizationCatalog.skinToneOptions.first.id,
      hairOptionId: HeroCustomizationCatalog.hairOptions.first.id,
      outfitOptionId: HeroCustomizationCatalog.outfitOptions.first.id,
      shoesOptionId: HeroCustomizationCatalog.shoesOptions.first.id,
      backpackOptionId: HeroCustomizationCatalog.backpackOptions.first.id,
      accessoryId: AccessoryCatalog.options.first.id,
    );
  }

  /// [skinToneId] and [accessoryId] fall back to their defaults for a
  /// save written before the Phase 2 redesign added them, so an existing
  /// player's hero keeps loading instead of resetting.
  factory HeroProfile.fromJson(Map<String, dynamic> json) {
    final fallback = HeroProfile.initial();
    return HeroProfile(
      skinToneId: json['skinToneId'] as String? ?? fallback.skinToneId,
      hairOptionId: json['hairOptionId'] as String? ?? fallback.hairOptionId,
      outfitOptionId:
          json['outfitOptionId'] as String? ?? fallback.outfitOptionId,
      shoesOptionId:
          json['shoesOptionId'] as String? ?? fallback.shoesOptionId,
      backpackOptionId:
          json['backpackOptionId'] as String? ?? fallback.backpackOptionId,
      accessoryId: json['accessoryId'] as String? ?? fallback.accessoryId,
    );
  }

  final String skinToneId;
  final String hairOptionId;
  final String outfitOptionId;
  final String shoesOptionId;
  final String backpackOptionId;
  final String accessoryId;

  HeroProfile copyWith({
    String? skinToneId,
    String? hairOptionId,
    String? outfitOptionId,
    String? shoesOptionId,
    String? backpackOptionId,
    String? accessoryId,
  }) {
    return HeroProfile(
      skinToneId: skinToneId ?? this.skinToneId,
      hairOptionId: hairOptionId ?? this.hairOptionId,
      outfitOptionId: outfitOptionId ?? this.outfitOptionId,
      shoesOptionId: shoesOptionId ?? this.shoesOptionId,
      backpackOptionId: backpackOptionId ?? this.backpackOptionId,
      accessoryId: accessoryId ?? this.accessoryId,
    );
  }

  Map<String, dynamic> toJson() => {
        'skinToneId': skinToneId,
        'hairOptionId': hairOptionId,
        'outfitOptionId': outfitOptionId,
        'shoesOptionId': shoesOptionId,
        'backpackOptionId': backpackOptionId,
        'accessoryId': accessoryId,
      };
}
