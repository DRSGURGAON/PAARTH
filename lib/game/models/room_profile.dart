/// The child's Player Room: one equipped decoration id per slot, or
/// null for an empty slot. Unlike `HeroProfile` (always has a free
/// default in every category), every room slot starts genuinely empty
/// — every room decoration is shop-only (see `ShopCatalog`).
class RoomProfile {
  const RoomProfile({
    this.wallArtItemId,
    this.rugItemId,
    this.plantItemId,
    this.lampItemId,
  });

  const RoomProfile.empty() : this();

  factory RoomProfile.fromJson(Map<String, dynamic> json) {
    return RoomProfile(
      wallArtItemId: json['wallArtItemId'] as String?,
      rugItemId: json['rugItemId'] as String?,
      plantItemId: json['plantItemId'] as String?,
      lampItemId: json['lampItemId'] as String?,
    );
  }

  final String? wallArtItemId;
  final String? rugItemId;
  final String? plantItemId;
  final String? lampItemId;

  Map<String, dynamic> toJson() => {
        'wallArtItemId': wallArtItemId,
        'rugItemId': rugItemId,
        'plantItemId': plantItemId,
        'lampItemId': lampItemId,
      };
}
