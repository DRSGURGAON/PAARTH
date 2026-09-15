import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A soft, rounded card for the gentle "wrong answer" moment: the
/// encouragement message, an optional hint line/visual, and an
/// optional action (Memory Master's "Look again", say) — all sized to
/// their real content instead of a fixed-height box.
///
/// Every mini-game used to float this as bare colored text inside a
/// fixed-height `SizedBox`, which looked plain and, in Memory Master,
/// genuinely overflowed: the encouragement text can wrap to two lines
/// on some devices, and that screen additionally nested a full button
/// inside the same fixed box. Centralizing the card here fixes both
/// problems at once — a real container that grows with its content —
/// and gives every miss the same warm, designed look across the app.
class AnswerFeedbackBanner extends StatelessWidget {
  const AnswerFeedbackBanner({
    required this.message,
    this.hintText,
    this.hintVisual,
    this.action,
    super.key,
  });

  /// The rotating encouragement line ("Almost! Let's try again! 💪").
  final String message;

  /// Optional gentle hint text ("Count them all one by one!").
  final String? hintText;

  /// Optional hint visual line (a redrawn pattern, counted emoji, ...).
  final String? hintVisual;

  /// Optional action shown under the message (e.g. a "Look again"
  /// button) — part of the card's own content, so it can never be
  /// clipped by a separately-sized container around it.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gentleWarning.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gentleWarning.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.gentleWarning),
          ),
          if (hintText != null) ...[
            const SizedBox(height: 6),
            Text(
              '💡 $hintText',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
          if (hintVisual != null) ...[
            const SizedBox(height: 4),
            Text(
              hintVisual!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 2),
            action!,
          ],
        ],
      ),
    );
  }
}
