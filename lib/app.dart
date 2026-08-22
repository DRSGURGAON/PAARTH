import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/route_names.dart';
import 'core/theme/app_theme.dart';

/// Root widget: wires up theme, initial route and route generation.
/// Deliberately has no other responsibility — service setup happens in
/// `main.dart` before this is even built.
class SuperKidAdventureApp extends StatelessWidget {
  const SuperKidAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
