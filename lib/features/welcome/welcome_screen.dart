import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/repositories/hero_repository.dart';
import '../../shared/widgets/big_rounded_button.dart';

/// Landing screen after splash: game branding + a single, unmistakable
/// action. No sign-up, no account, no personal information — per the
/// child-safety requirements, the child should be playing within two
/// taps of opening the app. A returning player (a hero was already
/// saved) sees "Continue Adventure" and goes straight back to Home
/// instead of rebuilding their hero every launch.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSavedProfile =
        HeroRepository(AppScope.of(context).storage).hasSavedProfile;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              const _Mascot(),
              const SizedBox(height: 32),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkNavy.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(flex: 2),
              BigRoundedButton(
                label: hasSavedProfile ? 'Continue Adventure' : 'PLAY',
                icon: hasSavedProfile
                    ? Icons.arrow_forward_rounded
                    : Icons.play_arrow_rounded,
                backgroundColor: AppColors.coral,
                onPressed: () => Navigator.of(context).pushReplacementNamed(
                  hasSavedProfile
                      ? RouteNames.home
                      : RouteNames.heroPresetSelection,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: const BoxDecoration(
        color: AppColors.leafGreen,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.emoji_emotions_rounded,
        size: 96,
        color: Colors.white,
      ),
    );
  }
}
