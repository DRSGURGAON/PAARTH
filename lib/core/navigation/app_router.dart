import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
import 'route_names.dart';

/// Single source of truth for turning a route name into a screen.
/// Deliberately plain `Navigator`/`onGenerateRoute` rather than a routing
/// package — V1's navigation is a simple forward/back stack, so a
/// dependency isn't earning its keep yet.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _pageRoute(const SplashScreen(), settings);
      case RouteNames.welcome:
        return _pageRoute(const WelcomeScreen(), settings);
      case RouteNames.heroSelection:
        return _pageRoute(
          const PlaceholderScreen(
            title: 'Hero Selection',
            arrivingIn: 'Arriving in Phase 2 — pick your hero and start '
                'your adventure!',
          ),
          settings,
        );
      default:
        return _pageRoute(
          Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _pageRoute(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}
