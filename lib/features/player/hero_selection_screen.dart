import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/hero_customization_catalog.dart';
import '../../game/models/customization_option.dart';
import '../../game/models/hero_profile.dart';
import '../../game/repositories/hero_repository.dart';
import '../../shared/widgets/big_rounded_button.dart';
import 'hero_avatar_preview.dart';

/// Lets the child build their hero from four swatch categories, then
/// saves it and starts the adventure. No text entry, no personal
/// information — every choice is a single tap on a big color circle.
class HeroSelectionScreen extends StatefulWidget {
  const HeroSelectionScreen({super.key});

  @override
  State<HeroSelectionScreen> createState() => _HeroSelectionScreenState();
}

class _HeroSelectionScreenState extends State<HeroSelectionScreen> {
  late HeroRepository _heroRepository;
  late HeroProfile _profile;
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
    _heroRepository = HeroRepository(AppScope.of(context).storage);
    _profile = _heroRepository.load();
    _loaded = true;
  }

  void _select({
    String? hairOptionId,
    String? outfitOptionId,
    String? shoesOptionId,
    String? backpackOptionId,
  }) {
    setState(() {
      _profile = _profile.copyWith(
        hairOptionId: hairOptionId,
        outfitOptionId: outfitOptionId,
        shoesOptionId: shoesOptionId,
        backpackOptionId: backpackOptionId,
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
                    label: 'Hair',
                    options: HeroCustomizationCatalog.hairOptions,
                    selectedId: _profile.hairOptionId,
                    onSelected: (id) => _select(hairOptionId: id),
                  ),
                  _CategoryPicker(
                    label: 'Outfit',
                    options: HeroCustomizationCatalog.outfitOptions,
                    selectedId: _profile.outfitOptionId,
                    onSelected: (id) => _select(outfitOptionId: id),
                  ),
                  _CategoryPicker(
                    label: 'Shoes',
                    options: HeroCustomizationCatalog.shoesOptions,
                    selectedId: _profile.shoesOptionId,
                    onSelected: (id) => _select(shoesOptionId: id),
                  ),
                  _CategoryPicker(
                    label: 'Backpack',
                    options: HeroCustomizationCatalog.backpackOptions,
                    selectedId: _profile.backpackOptionId,
                    onSelected: (id) => _select(backpackOptionId: id),
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
