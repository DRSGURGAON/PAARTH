import '../models/accessory_option.dart';

/// The fixed set of accessory choices offered in Hero Selection /
/// Customization (Phase 2 redesign brief section 1). "None" is always
/// first and is the default for every new hero.
class AccessoryCatalog {
  AccessoryCatalog._();

  static const List<AccessoryOption> options = [
    AccessoryOption(id: 'none', label: 'None', emoji: null),
    AccessoryOption(id: 'sunglasses', label: 'Sunglasses', emoji: '🕶️'),
    AccessoryOption(id: 'bow', label: 'Bow', emoji: '🎀'),
    AccessoryOption(id: 'cape', label: 'Cape', emoji: '🧣'),
    AccessoryOption(id: 'flower', label: 'Flower', emoji: '🌸'),
  ];
}
