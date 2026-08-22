import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/hero_preset_catalog.dart';
import '../../game/repositories/hero_repository.dart';
import '../../shared/widgets/big_rounded_button.dart';
import 'hero_avatar_preview.dart';

/// First-run hero picker (Phase 2 redesign brief section 1): browse a
/// carousel of original preset looks with Previous/Next, confirm one
/// with Select, then Continue into the game. No text entry — the child
/// never has to type a name or anything else personal. Fine-grained
/// re-customization (individual hair/outfit/skin/accessory swatches)
/// stays on the separate detailed [HeroSelectionScreen], reachable later
/// from the Room, so this screen only has to make a good first choice
/// fast — not replace that screen.
class HeroPresetSelectionScreen extends StatefulWidget {
  const HeroPresetSelectionScreen({super.key});

  @override
  State<HeroPresetSelectionScreen> createState() =>
      _HeroPresetSelectionScreenState();
}

class _HeroPresetSelectionScreenState
    extends State<HeroPresetSelectionScreen> {
  int _previewIndex = 0;
  int? _selectedIndex;

  void _previous() {
    setState(() {
      _previewIndex = (_previewIndex - 1 + HeroPresetCatalog.presets.length) %
          HeroPresetCatalog.presets.length;
    });
  }

  void _next() {
    setState(() {
      _previewIndex = (_previewIndex + 1) % HeroPresetCatalog.presets.length;
    });
  }

  void _select() {
    setState(() => _selectedIndex = _previewIndex);
  }

  Future<void> _continue() async {
    final selectedIndex = _selectedIndex;
    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap Select to choose your hero first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final storage = AppScope.of(context).storage;
    await HeroRepository(storage).save(HeroPresetCatalog.presets[selectedIndex]);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final preset = HeroPresetCatalog.presets[_previewIndex];
    final isCurrentSelected = _selectedIndex == _previewIndex;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Hero')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavArrow(
                    icon: Icons.chevron_left_rounded,
                    label: 'Previous hero',
                    onTap: _previous,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeroAvatarPreview(
                          key: ValueKey('preset_preview_$_previewIndex'),
                          profile: preset,
                          size: 200,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hero ${_previewIndex + 1} of '
                          '${HeroPresetCatalog.presets.length}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  _NavArrow(
                    icon: Icons.chevron_right_rounded,
                    label: 'Next hero',
                    onTap: _next,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  BigRoundedButton(
                    label: isCurrentSelected ? 'Selected!' : 'Select',
                    icon: isCurrentSelected
                        ? Icons.check_circle_rounded
                        : Icons.touch_app_rounded,
                    backgroundColor:
                        isCurrentSelected ? AppColors.leafGreen : AppColors.skyBlue,
                    onPressed: _select,
                  ),
                  const SizedBox(height: 12),
                  BigRoundedButton(
                    label: 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    backgroundColor: _selectedIndex == null
                        ? Colors.grey.shade400
                        : AppColors.coral,
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 40,
      // Comfortably clears the 44x44 logical-pixel minimum touch target
      // (brief section 13) once padding is included.
      padding: const EdgeInsets.all(12),
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.inkNavy),
    );
  }
}
