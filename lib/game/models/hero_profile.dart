import '../data/hero_customization_catalog.dart';

/// The child's chosen hero appearance. Holds option *ids* only (never
/// [Color]s or widgets) so it stays trivially JSON-serializable for
/// local save/load (Phase 11) and, later, cloud sync.
class HeroProfile {
  const HeroProfile({
    required this.hairOptionId,
    required this.outfitOptionId,
    required this.shoesOptionId,
    required this.backpackOptionId,
  });

  /// Default hero shown the first time a child opens the game: the first
  /// option in each category.
  factory HeroProfile.initial() {
    return HeroProfile(
      hairOptionId: HeroCustomizationCatalog.hairOptions.first.id,
      outfitOptionId: HeroCustomizationCatalog.outfitOptions.first.id,
      shoesOptionId: HeroCustomizationCatalog.shoesOptions.first.id,
      backpackOptionId: HeroCustomizationCatalog.backpackOptions.first.id,
    );
  }

  factory HeroProfile.fromJson(Map<String, dynamic> json) {
    final fallback = HeroProfile.initial();
    return HeroProfile(
      hairOptionId: json['hairOptionId'] as String? ?? fallback.hairOptionId,
      outfitOptionId:
          json['outfitOptionId'] as String? ?? fallback.outfitOptionId,
      shoesOptionId:
          json['shoesOptionId'] as String? ?? fallback.shoesOptionId,
      backpackOptionId:
          json['backpackOptionId'] as String? ?? fallback.backpackOptionId,
    );
  }

  final String hairOptionId;
  final String outfitOptionId;
  final String shoesOptionId;
  final String backpackOptionId;

  HeroProfile copyWith({
    String? hairOptionId,
    String? outfitOptionId,
    String? shoesOptionId,
    String? backpackOptionId,
  }) {
    return HeroProfile(
      hairOptionId: hairOptionId ?? this.hairOptionId,
      outfitOptionId: outfitOptionId ?? this.outfitOptionId,
      shoesOptionId: shoesOptionId ?? this.shoesOptionId,
      backpackOptionId: backpackOptionId ?? this.backpackOptionId,
    );
  }

  Map<String, dynamic> toJson() => {
        'hairOptionId': hairOptionId,
        'outfitOptionId': outfitOptionId,
        'shoesOptionId': shoesOptionId,
        'backpackOptionId': backpackOptionId,
      };
}
