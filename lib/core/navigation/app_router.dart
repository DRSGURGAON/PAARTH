import 'package:flutter/material.dart';

import '../../features/adventure_map/adventure_map_screen.dart';
import '../../features/collection/collection_screen.dart';
import '../../features/companions/companion_select_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/mini_games/mini_games_screen.dart';
import '../../features/player/hero_selection_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
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
        return _pageRoute(const HeroSelectionScreen(), settings);
      case RouteNames.home:
        return _pageRoute(const HomeScreen(), settings);
      case RouteNames.adventureMap:
        return _pageRoute(const AdventureMapScreen(), settings);
      case RouteNames.miniGames:
        return _pageRoute(const MiniGamesScreen(), settings);
      case RouteNames.collection:
        return _pageRoute(const CollectionScreen(), settings);
      case RouteNames.companions:
        return _pageRoute(const CompanionSelectScreen(), settings);
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
