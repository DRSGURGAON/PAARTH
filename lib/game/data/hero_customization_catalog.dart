import 'package:flutter/material.dart';

import '../models/customization_option.dart';

/// The fixed set of choices offered in Hero Selection / Customization.
/// V1 ships 4 options per category (no real art yet — see the README's
/// Assets section), but nothing about the picker UI or [HeroProfile]
/// assumes exactly 4; more can be appended here freely.
class HeroCustomizationCatalog {
  HeroCustomizationCatalog._();

  static const List<CustomizationOption> hairOptions = [
    CustomizationOption(id: 'sunshine', label: 'Sunshine', color: Color(0xFFFFC93C)),
    CustomizationOption(id: 'berry', label: 'Berry', color: Color(0xFF9B6BFF)),
    CustomizationOption(id: 'midnight', label: 'Midnight', color: Color(0xFF2A2E43)),
    CustomizationOption(id: 'copper', label: 'Copper', color: Color(0xFFE07A46)),
  ];

  static const List<CustomizationOption> outfitOptions = [
    CustomizationOption(id: 'coral', label: 'Coral', color: Color(0xFFFF6F59)),
    CustomizationOption(id: 'sky', label: 'Sky', color: Color(0xFF3DC0F0)),
    CustomizationOption(id: 'grape', label: 'Grape', color: Color(0xFF9B6BFF)),
    CustomizationOption(id: 'leaf', label: 'Leaf', color: Color(0xFF4CD07D)),
  ];

  static const List<CustomizationOption> shoesOptions = [
    CustomizationOption(id: 'sunny', label: 'Sunny', color: Color(0xFFFFC93C)),
    CustomizationOption(id: 'ocean', label: 'Ocean', color: Color(0xFF2E86C1)),
    CustomizationOption(id: 'flame', label: 'Flame', color: Color(0xFFE8544B)),
    CustomizationOption(id: 'mint', label: 'Mint', color: Color(0xFF3FC79A)),
  ];

  static const List<CustomizationOption> backpackOptions = [
    CustomizationOption(id: 'ranger', label: 'Ranger', color: Color(0xFF4CD07D)),
    CustomizationOption(id: 'explorer', label: 'Explorer', color: Color(0xFFE07A46)),
    CustomizationOption(id: 'star', label: 'Star', color: Color(0xFFFFC93C)),
    CustomizationOption(id: 'cosmic', label: 'Cosmic', color: Color(0xFF9B6BFF)),
  ];
}
