import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';

/// First screen shown on launch: animates the game logo in, then hands
/// off to the Welcome screen once the animation has had time to play
/// (never faster than [AppConstants.splashMinDuration], so it doesn't
/// flash by unread on a fast device).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _controller.forward();
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    await Future.delayed(AppConstants.splashMinDuration);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.sunshineYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 84,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
