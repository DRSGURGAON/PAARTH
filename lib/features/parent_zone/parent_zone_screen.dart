import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../game/models/quest.dart';
import '../../game/quests/quest_catalog.dart';
import '../../game/repositories/play_time_repository.dart';
import '../../game/repositories/quest_repository.dart';
import '../../game/repositories/settings_repository.dart';
import '../../game/systems/difficulty_tracker.dart';

/// The Parent Zone dashboard (design brief: "Shows play time, quests
/// completed, per-subject progress, recommended practice area"). Every
/// number here is read live from the same repositories the game itself
/// writes to — there is no separate "reporting" copy of the data that
/// could drift out of sync.
class ParentZoneScreen extends StatelessWidget {
  const ParentZoneScreen({super.key});

  static const Map<ChallengeCategory, String> _subjectLabels = {
    ChallengeCategory.math: 'Math',
    ChallengeCategory.logic: 'Patterns & Logic',
    ChallengeCategory.memory: 'Memory',
    ChallengeCategory.english: 'Words',
  };

  static const Map<ChallengeCategory, String> _practiceGame = {
    ChallengeCategory.math: 'Math Dash',
    ChallengeCategory.logic: 'Pattern Power',
    ChallengeCategory.memory: 'Memory Master',
    ChallengeCategory.english: 'Word Builder',
  };

  @override
  Widget build(BuildContext context) {
    final storage = AppScope.of(context).storage;
    final playSeconds = PlayTimeRepository(storage).totalSeconds;
    final completedQuests = QuestRepository(storage).completedQuestIds().length;
    final tracker = DifficultyTracker(storage);
    final levels = {
      for (final category in ChallengeCategory.values)
        category: tracker.levelFor(category),
    };
    final weakest = _weakestSubject(levels);

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Zone')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'For grown-ups. No purchases in this app, and nothing '
              'here ever leaves this device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _StatCard(
              icon: Icons.schedule_rounded,
              color: AppColors.skyBlue,
              title: 'Play Time',
              value: DurationFormatter.playTime(Duration(seconds: playSeconds)),
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.flag_rounded,
              color: AppColors.leafGreen,
              title: 'Quests Completed',
              value: '$completedQuests of ${QuestCatalog.all.length}',
            ),
            const SizedBox(height: 20),
            Text(
              'Subject Progress',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            for (final category in ChallengeCategory.values) ...[
              _SubjectProgressRow(
                label: _subjectLabels[category]!,
                level: levels[category]!,
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            Card(
              key: const ValueKey('recommended_practice_card'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Practice',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_subjectLabels[weakest]} is the newest skill — '
                      'try a round of ${_practiceGame[weakest]} together.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 8),
            const _SettingsSection(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                key: const ValueKey('reset_progress_button'),
                onPressed: () => _confirmReset(context),
                icon: const Icon(Icons.delete_forever_rounded, color: AppColors.gentleWarning),
                label: const Text(
                  'Reset All Progress',
                  style: TextStyle(color: AppColors.gentleWarning),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'This clears every star, coin, quest, badge, companion, shop '
          'purchase, and play-time record on this device. This cannot '
          'be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const ValueKey('confirm_reset_button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    await AppScope.of(context).storage.clearAll();
    if (!context.mounted) return;

    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteNames.welcome, (route) => false);
  }

  /// The lowest-level subject, ties broken by [ChallengeCategory.values]'
  /// declared order — deterministic, not random, so the same progress
  /// always yields the same recommendation.
  ChallengeCategory _weakestSubject(Map<ChallengeCategory, int> levels) {
    var weakest = ChallengeCategory.values.first;
    for (final category in ChallengeCategory.values) {
      if (levels[category]! < levels[weakest]!) weakest = category;
    }
    return weakest;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sound Effects / Haptic Feedback toggles, both on by default (see
/// [SettingsRepository]). Its own small stateful island rather than
/// making the whole dashboard stateful, since nothing else on this
/// screen needs to react to a local toggle without a full re-open.
class _SettingsSection extends StatefulWidget {
  const _SettingsSection();

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  late SettingsRepository _settings;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _settings = SettingsRepository(AppScope.of(context).storage);
    _loaded = true;
  }

  Future<void> _setSoundEnabled(bool value) async {
    await _settings.setSoundEnabled(value);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _setHapticsEnabled(bool value) async {
    await _settings.setHapticsEnabled(value);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _setInstrumentSoundsEnabled(bool value) async {
    await _settings.setInstrumentSoundsEnabled(value);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sound & Haptics',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SwitchListTile(
          key: const ValueKey('sound_toggle'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound Effects'),
          value: _settings.soundEnabled,
          onChanged: _setSoundEnabled,
        ),
        SwitchListTile(
          key: const ValueKey('haptics_toggle'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic Feedback'),
          value: _settings.hapticsEnabled,
          onChanged: _setHapticsEnabled,
        ),
        SwitchListTile(
          key: const ValueKey('instrument_sounds_toggle'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Instrument Sounds'),
          subtitle: const Text('Piano and Guitar notes'),
          value: _settings.instrumentSoundsEnabled,
          onChanged: _setInstrumentSoundsEnabled,
        ),
      ],
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  const _SubjectProgressRow({required this.label, required this.level});

  final String label;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: level / DifficultyTracker.maxLevel,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.coral,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('Lv $level', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
