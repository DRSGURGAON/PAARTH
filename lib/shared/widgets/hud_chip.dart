import 'package:flutter/material.dart';

/// The small white pill used across every mini-game's top HUD row
/// (score, streak, round progress, ...). Was duplicated per-screen as a
/// flat, shadowless container; centralizing it here — with a soft
/// shadow for a little depth — makes every game's HUD consistent and
/// gives the whole app a less "flat" look in one small, purely visual
/// change.
class HudChip extends StatelessWidget {
  const HudChip({required this.text, required this.semanticLabel, super.key});

  final String text;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
