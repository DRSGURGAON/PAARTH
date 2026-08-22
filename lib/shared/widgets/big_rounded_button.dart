import 'package:flutter/material.dart';

/// The one primary call-to-action button style used everywhere in the
/// game ("Play", "Continue", "Repair the bridge!", ...). Centralizing it
/// here means every screen automatically matches section 14's
/// large-button / large-touch-target requirement, and a single tweak
/// here updates every CTA in the game at once.
class BigRoundedButton extends StatelessWidget {
  const BigRoundedButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Text(label),
            ],
          );

    return FilledButton(
      onPressed: onPressed,
      style: backgroundColor == null && foregroundColor == null
          ? null
          : FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            ),
      child: child,
    );
  }
}
