import 'package:flutter/material.dart';

/// Scales [child] in from nothing with a bouncy overshoot, once, on
/// first build — the small bit of "juice" a static reward/result icon
/// was missing. Deliberately a one-shot `TweenAnimationBuilder` rather
/// than a controller-driven widget: nothing here needs to be re-played
/// or interrupted, so there's no extra state to manage.
class PopIn extends StatelessWidget {
  const PopIn({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: child,
    );
  }
}
