import 'package:flutter/material.dart';

import '../models/shop_item.dart';

/// Everything coins can buy (design brief section 11's shop / room
/// decoration economy — the reason Phase 7 introduced a second
/// currency). Two paid options per slot: hero categories extend the
/// free starter swatches from `HeroCustomizationCatalog`; room slots
/// (wall art / rug / plant / lamp) are entirely shop-only, since the
/// Player Room starts empty.
class ShopCatalog {
  ShopCatalog._();

  static const List<ShopItem> all = [
    // Hero — extra hair colors.
    ShopItem(
      id: 'hair_rose',
      category: ShopCategory.hair,
      label: 'Rose',
      color: Color(0xFFFF9AD5),
      price: 10,
    ),
    ShopItem(
      id: 'hair_ocean',
      category: ShopCategory.hair,
      label: 'Ocean',
      color: Color(0xFF2AA9A0),
      price: 20,
    ),

    // Hero — extra outfit colors.
    ShopItem(
      id: 'outfit_sunset',
      category: ShopCategory.outfit,
      label: 'Sunset',
      color: Color(0xFFFF8A3D),
      price: 10,
    ),
    ShopItem(
      id: 'outfit_galaxy',
      category: ShopCategory.outfit,
      label: 'Galaxy',
      color: Color(0xFF4B3F8F),
      price: 20,
    ),

    // Hero — extra shoe colors.
    ShopItem(
      id: 'shoes_gold',
      category: ShopCategory.shoes,
      label: 'Gold',
      color: Color(0xFFE8B93C),
      price: 10,
    ),
    ShopItem(
      id: 'shoes_silver',
      category: ShopCategory.shoes,
      label: 'Silver',
      color: Color(0xFFB8C0CC),
      price: 20,
    ),

    // Hero — extra backpack colors.
    ShopItem(
      id: 'backpack_royal',
      category: ShopCategory.backpack,
      label: 'Royal',
      color: Color(0xFF5B4FCF),
      price: 10,
    ),
    ShopItem(
      id: 'backpack_sunrise',
      category: ShopCategory.backpack,
      label: 'Sunrise',
      color: Color(0xFFFFA23C),
      price: 20,
    ),

    // Room — wall art.
    ShopItem(
      id: 'wallart_stars',
      category: ShopCategory.wallArt,
      label: 'Starry Sky',
      color: Color(0xFF3B5BA9),
      price: 10,
    ),
    ShopItem(
      id: 'wallart_rainbow',
      category: ShopCategory.wallArt,
      label: 'Rainbow',
      color: Color(0xFFEF6C9B),
      price: 20,
    ),

    // Room — rugs.
    ShopItem(
      id: 'rug_stripes',
      category: ShopCategory.rug,
      label: 'Stripes',
      color: Color(0xFFE07A46),
      price: 10,
    ),
    ShopItem(
      id: 'rug_clouds',
      category: ShopCategory.rug,
      label: 'Clouds',
      color: Color(0xFFAEE2F2),
      price: 20,
    ),

    // Room — plants.
    ShopItem(
      id: 'plant_cactus',
      category: ShopCategory.plant,
      label: 'Cactus',
      color: Color(0xFF3FA75C),
      price: 10,
    ),
    ShopItem(
      id: 'plant_flowers',
      category: ShopCategory.plant,
      label: 'Flowers',
      color: Color(0xFFD64D8C),
      price: 20,
    ),

    // Room — lamps.
    ShopItem(
      id: 'lamp_moon',
      category: ShopCategory.lamp,
      label: 'Moon Lamp',
      color: Color(0xFFCBB6E8),
      price: 10,
    ),
    ShopItem(
      id: 'lamp_rocket',
      category: ShopCategory.lamp,
      label: 'Rocket Lamp',
      color: Color(0xFFE8544B),
      price: 20,
    ),
  ];

  static List<ShopItem> itemsFor(ShopCategory category) =>
      all.where((item) => item.category == category).toList();
}
