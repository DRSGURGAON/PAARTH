import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A chunky, rounded progress bar for the top of a mini-game session —
/// the signature "how far through this lesson am I" bar Duolingo shows.
/// Fills smoothly as the child advances, giving a clear sense of
/// momentum that the bare "N / M" chip alone did not. Purely visual.
class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    required this.current,
    required this.total,
    this.color = AppColors.leafGreen,
    super.key,
  });

  /// How many steps are done (0..total). The bar shows [current]/[total].
  final int current;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

    return Semantics(
      label: 'Progress: $current of $total',
      // An explicit full-width, fixed-height track so the fill's
      // FractionallySizedBox always has a bounded box to take a
      // fraction of (a bare Stack here could collapse to zero width).
      child: SizedBox(
        width: double.infinity,
        height: 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: Colors.black.withValues(alpha: 0.06)),
              Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: fraction),
                  builder: (context, value, _) => FractionallySizedBox(
                    widthFactor: value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
