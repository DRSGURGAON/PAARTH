import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import 'quest_complete_screen.dart';

/// The story payoff between the last challenge and the celebration
/// (brief section 12): the quest's resolution beats appear one at a
/// time — hero arrives, pieces attach, bridge repairs, animal crosses —
/// so the child sees their challenge rewards directly fixing the story
/// problem. Tap-driven (each tap pops in the next beat) rather than
/// timer-driven: the child controls the pace, tests stay deterministic,
/// and reduced-motion needs are respected by keeping each step to a
/// single light pop-in.
class QuestResolutionScreen extends StatefulWidget {
  const QuestResolutionScreen({
    required this.quest,
    required this.starsAwarded,
    required this.coinsAwarded,
    super.key,
  });

  final Quest quest;
  final int starsAwarded;
  final int coinsAwarded;

  @override
  State<QuestResolutionScreen> createState() => _QuestResolutionScreenState();
}

class _QuestResolutionScreenState extends State<QuestResolutionScreen> {
  int _revealed = 1;

  bool get _allRevealed => _revealed >= widget.quest.resolutionSteps.length;

  void _advance() {
    if (_allRevealed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => QuestCompleteScreen(
            quest: widget.quest,
            starsAwarded: widget.starsAwarded,
            coinsAwarded: widget.coinsAwarded,
          ),
        ),
      );
    } else {
      setState(() => _revealed++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.quest.resolutionSteps;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                widget.quest.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < _revealed; i++)
                      PopIn(
                        key: ValueKey('resolution_step_$i'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            steps[i],
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              BigRoundedButton(
                label: _allRevealed ? 'Hooray!' : 'Next',
                icon: _allRevealed
                    ? Icons.celebration_rounded
                    : Icons.arrow_forward_rounded,
                backgroundColor:
                    _allRevealed ? AppColors.sunshineYellow : AppColors.skyBlue,
                onPressed: _advance,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
