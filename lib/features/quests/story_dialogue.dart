import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../shared/widgets/pop_in.dart';

/// Reusable story/dialogue presenter (brief section 5): a friendly
/// character, their name, and short dialogue lines shown one at a time
/// with a big Next button and a Skip option. Every quest — current and
/// future — uses this same component rather than a custom intro layout.
class StoryDialogue extends StatefulWidget {
  const StoryDialogue({
    required this.lines,
    required this.onFinished,
    this.npc,
    super.key,
  });

  /// Short lines shown one per step. Must not be empty.
  final List<String> lines;

  /// Called once the child taps Next on the last line, or taps Skip.
  final VoidCallback onFinished;

  /// The speaking character; null shows a generic storybook narrator.
  final QuestNpc? npc;

  @override
  State<StoryDialogue> createState() => _StoryDialogueState();
}

class _StoryDialogueState extends State<StoryDialogue> {
  int _step = 0;

  bool get _isLastLine => _step >= widget.lines.length - 1;

  void _next() {
    if (_isLastLine) {
      widget.onFinished();
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final npc = widget.npc;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopIn(
          child: Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppColors.leafGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: npc == null
                ? const Icon(Icons.auto_stories_rounded,
                    size: 56, color: Colors.white)
                : Text(npc.emoji, style: const TextStyle(fontSize: 56)),
          ),
        ),
        const SizedBox(height: 8),
        if (npc != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(npc.name, style: textTheme.titleMedium),
          ),
        const SizedBox(height: 16),
        // A fresh key per step makes each line pop in, a small bit of
        // life without a heavy animation.
        SizedBox(
          height: 96,
          child: Center(
            child: PopIn(
              key: ValueKey('dialogue_line_$_step'),
              child: Text(
                widget.lines[_step],
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.lines.length; i++)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i <= _step
                      ? AppColors.leafGreen
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('dialogue_next'),
          onPressed: _next,
          child: Text(_isLastLine ? "Let's go!" : 'Next'),
        ),
        if (!_isLastLine)
          TextButton(
            key: const ValueKey('dialogue_skip'),
            onPressed: widget.onFinished,
            child: const Text('Skip story'),
          ),
      ],
    );
  }
}
