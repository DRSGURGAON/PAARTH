import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../shared/widgets/big_rounded_button.dart';

/// The celebration moment: story outro + stars earned (or a practice
/// cheer on replays, since stars are only awarded once per quest).
class QuestCompleteScreen extends StatefulWidget {
  const QuestCompleteScreen({
    required this.quest,
    required this.starsAwarded,
    required this.coinsAwarded,
    super.key,
  });

  final Quest quest;
  final int starsAwarded;
  final int coinsAwarded;

  @override
  State<QuestCompleteScreen> createState() => _QuestCompleteScreenState();
}

class _QuestCompleteScreenState extends State<QuestCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_soundPlayed) return;
    _soundPlayed = true;
    if (widget.starsAwarded > 0) {
      FeedbackService(AppScope.of(context).storage).play(SoundEvent.reward);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isFirstClear = widget.starsAwarded > 0;

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.sunshineYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 84,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quest Complete!',
                textAlign: TextAlign.center,
                style: textTheme.displayMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                widget.quest.storyOutro,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  isFirstClear
                      ? '+${widget.starsAwarded} ⭐  +${widget.coinsAwarded} 🪙'
                      : 'Great practice! 🌟',
                  style: textTheme.headlineMedium,
                ),
              ),
              const Spacer(flex: 2),
              BigRoundedButton(
                label: 'Back to Map',
                icon: Icons.map_rounded,
                backgroundColor: AppColors.leafGreen,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
