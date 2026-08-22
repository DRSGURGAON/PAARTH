import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/tracking/play_time_tracker.dart';

/// Root widget: wires up theme, initial route, route generation, and
/// Parent Zone's play-time tracking. Deliberately has no other
/// responsibility — service setup happens in `main.dart` before this
/// is even built.
class SuperKidAdventureApp extends StatelessWidget {
  const SuperKidAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayTimeTracker(
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
