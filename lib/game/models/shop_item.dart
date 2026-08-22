import 'package:flutter/material.dart';

/// The 8 customizable slots the Shop sells into: the 4 hero categories
/// from Hero Selection, plus 4 Player Room decoration slots. Kept as
/// one enum (rather than two separate hero/room enums) so the Shop
/// screen can group and filter with a single switch.
enum ShopCategory { hair, outfit, shoes, backpack, wallArt, rug, plant, lamp }

/// One purchasable item. Shares the same "id + label + color" shape as
/// [CustomizationOption] (a shop item becomes exactly that once owned
/// and equipped) plus a coin [price] — see `ShopRepository` for
/// ownership and `CoinRepository.spendCoins` for the transaction.
class ShopItem {
  const ShopItem({
    required this.id,
    required this.category,
    required this.label,
    required this.color,
    required this.price,
  });

  final String id;
  final ShopCategory category;
  final String label;
  final Color color;
  final int price;

  bool get isHeroItem =>
      category == ShopCategory.hair ||
      category == ShopCategory.outfit ||
      category == ShopCategory.shoes ||
      category == ShopCategory.backpack;

  bool get isRoomItem => !isHeroItem;
}
