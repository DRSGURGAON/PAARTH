import 'package:flutter/material.dart';

/// One choice within a hero customization category (hair, outfit, shoes,
/// backpack). Deliberately generic — every category is "a labeled color
/// swatch" for V1, so the same widget/model drives all four pickers.
/// Swapping in real illustrated options later only means adding an
/// `assetPath` field here, not restructuring the picker UI.
class CustomizationOption {
  const CustomizationOption({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;
}
