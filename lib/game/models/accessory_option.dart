/// One accessory choice for a hero (Phase 2 redesign brief section 1).
/// Rendered as an emoji overlay rather than a color swatch — unlike hair/
/// outfit/shoes/backpack, an accessory isn't "a colored shape," it's a
/// distinct worn item. [emoji] is null only for the "None" option, which
/// every hero starts with.
class AccessoryOption {
  const AccessoryOption({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String? emoji;
}
