import 'package:flutter/material.dart';

import 'big_rounded_button.dart';

/// Honest "not built yet" screen for routes that exist in navigation
/// ahead of their phase landing (see the build-in-phases plan). Never
/// used to fake a finished feature — it clearly says what's missing and
/// always gives the child a working way back.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.arrivingIn,
    super.key,
  });

  final String title;
  final String arrivingIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction_rounded, size: 96),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                arrivingIn,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              BigRoundedButton(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
