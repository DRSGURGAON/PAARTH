import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/accessory_catalog.dart';
import '../../game/data/hero_customization_catalog.dart';
import '../../game/data/shop_catalog.dart';
import '../../game/models/accessory_option.dart';
import '../../game/models/customization_option.dart';
import '../../game/models/hero_profile.dart';
import '../../game/models/shop_item.dart';
import '../../game/repositories/hero_repository.dart';
import '../../game/repositories/shop_repository.dart';
import '../../shared/widgets/big_rounded_button.dart';
import 'hero_avatar_preview.dart';

/// Lets the child fine-tune their hero across six categories (skin tone,
/// hair, outfit, shoes, backpack, accessory), then saves it. No text
/// entry, no personal information — every choice is a single tap on a
/// big swatch. This is the detailed re-customize screen, reachable from
/// the Room; first-run hero creation instead uses the separate
/// HeroPresetSelectionScreen.
class HeroSelectionScreen extends StatefulWidget {
  const HeroSelectionScreen({super.key});

  @override
  State<HeroSelectionScreen> createState() => _HeroSelectionScreenState();
}

class _HeroSelectionScreenState extends State<HeroSelectionScreen> {
  late HeroRepository _heroRepository;
  late HeroProfile _profile;
  late List<CustomizationOption> _hairOptions;
  late List<CustomizationOption> _outfitOptions;
  late List<CustomizationOption> _shoesOptions;
  late List<CustomizationOption> _backpackOptions;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppScope is only reachable once this widget is in the tree, so the
    // lookup has to happen here rather than in initState. didChangeDependencies
    // can in principle fire more than once over the widget's life (e.g. on
    // reparenting) — guard with `_loaded` so a repeat call can't throw on
    // a `late` field or silently discard in-progress unsaved edits.
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _heroRepository = HeroRepository(storage);
    _profile = _heroRepository.load();
    final owned = ShopRepository(storage).ownedItemIds();
    _hairOptions = _withOwnedShopItems(
        HeroCustomizationCatalog.hairOptions, ShopCategory.hair, owned);
    _outfitOptions = _withOwnedShopItems(
        HeroCustomizationCatalog.outfitOptions, ShopCategory.outfit, owned);
    _shoesOptions = _withOwnedShopItems(
        HeroCustomizationCatalog.shoesOptions, ShopCategory.shoes, owned);
    _backpackOptions = _withOwnedShopItems(
        HeroCustomizationCatalog.backpackOptions, ShopCategory.backpack, owned);
    _loaded = true;
  }

  /// The free starter swatches plus any shop items the child has
  /// bought for this category — a purchase should show up as a new
  /// pickable swatch here, not just sit unused in the Shop.
  List<CustomizationOption> _withOwnedShopItems(
    List<CustomizationOption> freeOptions,
    ShopCategory category,
    Set<String> ownedItemIds,
  ) {
    return [
      ...freeOptions,
      for (final item in ShopCatalog.itemsFor(category))
        if (ownedItemIds.contains(item.id))
          CustomizationOption(id: item.id, label: item.label, color: item.color),
    ];
  }

  void _select({
    String? skinToneId,
    String? hairOptionId,
    String? outfitOptionId,
    String? shoesOptionId,
    String? backpackOptionId,
    String? accessoryId,
  }) {
    setState(() {
      _profile = _profile.copyWith(
        skinToneId: skinToneId,
        hairOptionId: hairOptionId,
        outfitOptionId: outfitOptionId,
        shoesOptionId: shoesOptionId,
        backpackOptionId: backpackOptionId,
        accessoryId: accessoryId,
      );
    });
  }

  Future<void> _startAdventure() async {
    await _heroRepository.save(_profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Build Your Hero')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            HeroAvatarPreview(profile: _profile, size: 180),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryPicker(
                    label: 'Skin Tone',
                    options: HeroCustomizationCatalog.skinToneOptions,
                    selectedId: _profile.skinToneId,
                    onSelected: (id) => _select(skinToneId: id),
                  ),
                  _CategoryPicker(
                    label: 'Hair',
                    options: _hairOptions,
                    selectedId: _profile.hairOptionId,
                    onSelected: (id) => _select(hairOptionId: id),
                  ),
                  _CategoryPicker(
                    label: 'Outfit',
                    options: _outfitOptions,
                    selectedId: _profile.outfitOptionId,
                    onSelected: (id) => _select(outfitOptionId: id),
                  ),
                  _CategoryPicker(
                    label: 'Shoes',
                    options: _shoesOptions,
                    selectedId: _profile.shoesOptionId,
                    onSelected: (id) => _select(shoesOptionId: id),
                  ),
                  _CategoryPicker(
                    label: 'Backpack',
                    options: _backpackOptions,
                    selectedId: _profile.backpackOptionId,
                    onSelected: (id) => _select(backpackOptionId: id),
                  ),
                  _AccessoryPicker(
                    selectedId: _profile.accessoryId,
                    onSelected: (id) => _select(accessoryId: id),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: BigRoundedButton(
                label: 'Start Adventure',
                icon: Icons.explore_rounded,
                backgroundColor: AppColors.leafGreen,
                onPressed: _startAdventure,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.label,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final String label;
  final List<CustomizationOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option.id == selectedId;
              return _Swatch(
                key: ValueKey('swatch_${option.id}'),
                option: option,
                isSelected: isSelected,
                onTap: () => onSelected(option.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final CustomizationOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.inkNavy : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: option.color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors [_CategoryPicker] for the one non-color category: accessories
/// are emoji badges (including a "None" choice), not color swatches.
class _AccessoryPicker extends StatelessWidget {
  const _AccessoryPicker({required this.selectedId, required this.onSelected});

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accessory', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AccessoryCatalog.options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = AccessoryCatalog.options[index];
              final isSelected = option.id == selectedId;
              return _AccessorySwatch(
                key: ValueKey('accessory_${option.id}'),
                option: option,
                isSelected: isSelected,
                onTap: () => onSelected(option.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AccessorySwatch extends StatelessWidget {
  const _AccessorySwatch({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final AccessoryOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.inkNavy : Colors.grey.shade300,
              width: 3,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.inkNavy.withOpacity(0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: option.emoji == null
              ? Icon(Icons.block_rounded, color: Colors.grey.shade400)
              : Text(option.emoji!, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
