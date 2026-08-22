import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/companion.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';

/// "My Companions" (design brief section 10): a grid of the 5
/// companions. Locked ones are greyed with the mini-game that unlocks
/// them; unlocked ones can be tapped to equip as the single active
/// helper mini-games check for. Equipping is instant and free — there's
/// no coin cost here, only the mini-game star that unlocked it.
class CompanionSelectScreen extends StatefulWidget {
  const CompanionSelectScreen({super.key});

  @override
  State<CompanionSelectScreen> createState() => CompanionSelectScreenState();
}

@visibleForTesting
class CompanionSelectScreenState extends State<CompanionSelectScreen> {
  late CompanionRepository _companionRepository;
  late Set<String> _unlockedIds;
  String? _selectedId;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _companionRepository = CompanionRepository(storage);
    _unlockedIds = CompanionCatalog.unlockedCompanionIds(
      MiniGameRepository(storage).starEarnedGameIds(),
    );
    _selectedId = _companionRepository.selectedCompanionId;
    _loaded = true;
  }

  Future<void> _select(Companion companion) async {
    await _companionRepository.selectCompanion(companion.id);
    if (!mounted) return;
    setState(() => _selectedId = companion.id);
  }

  @override
  Widget build(BuildContext context) {
    final companions = CompanionCatalog.all;

    return Scaffold(
      appBar: AppBar(title: const Text('My Companions')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                _selectedId == null
                    ? 'Tap a companion to bring them along!'
                    : 'Your active helper is highlighted.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: companions.length,
                itemBuilder: (context, index) {
                  final companion = companions[index];
                  final unlocked = _unlockedIds.contains(companion.id);
                  final selected = _selectedId == companion.id;
                  return _CompanionCard(
                    companion: companion,
                    unlocked: unlocked,
                    selected: selected,
                    onTap: unlocked ? () => _select(companion) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard({
    required this.companion,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final Companion companion;
  final bool unlocked;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      key: ValueKey('companion_${companion.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        color: unlocked ? Colors.white : const Color(0xFFF0F0F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: selected
              ? BorderSide(color: companion.color, width: 3)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: unlocked ? companion.color : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      unlocked ? companion.icon : Icons.lock_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  if (selected)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.leafGreen,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                companion.name,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  color: unlocked ? AppColors.inkNavy : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unlocked ? companion.abilityLabel : companion.description,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
