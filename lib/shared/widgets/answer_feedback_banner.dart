import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The gentle "not quite — try again" moment, redesigned to feel like
/// Duolingo's answer feedback: a warm, filled, rounded panel that
/// slides and fades up into place, with a friendly round icon, a bold
/// message and (optionally) a hint and an inline action.
///
/// It replaced an earlier version that floated bare text inside a thin
/// yellow-bordered card — which read as a harsh "yellow strip" on every
/// wrong answer. This one is a soft coral panel (never red/alarming for
/// a young child), sized to its own content so it can never overflow,
/// and shared by every screen so one warm, consistent look appears
/// everywhere a miss happens.
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
  /// button) — part of the panel's own content, so it can never be
  /// clipped by a separately-sized container around it.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // One-shot slide-up + fade on mount. The caller swaps a reserved
    // SizedBox for this banner the moment feedback appears, so the
    // widget mounts fresh each miss and the entrance plays every time.
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 18),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1EC), // soft coral tint
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.coral.withValues(alpha: 0.45),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('💪', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (hintText != null) ...[
              const SizedBox(height: 10),
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
              const SizedBox(height: 6),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
