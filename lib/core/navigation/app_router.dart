import 'package:flutter/material.dart';

import '../../features/activities/chess/chess_screen.dart';
import '../../features/activities/guitar/guitar_screen.dart';
import '../../features/activities/piano/piano_screen.dart';
import '../../features/adventure_map/world_select_screen.dart';
import '../../features/collection/collection_screen.dart';
import '../../features/companions/companion_select_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/mini_games/mini_games_screen.dart';
import '../../features/parent_zone/parent_gate_screen.dart';
import '../../features/parent_zone/parent_zone_screen.dart';
import '../../features/player/hero_preset_selection_screen.dart';
import '../../features/player/hero_selection_screen.dart';
import '../../features/room/room_screen.dart';
import '../../features/shop/shop_screen.dart';
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
      case RouteNames.heroPresetSelection:
        return _pageRoute(const HeroPresetSelectionScreen(), settings);
      case RouteNames.home:
        return _pageRoute(const HomeScreen(), settings);
      case RouteNames.adventureMap:
        return _pageRoute(const WorldSelectScreen(), settings);
      case RouteNames.miniGames:
        return _pageRoute(const MiniGamesScreen(), settings);
      case RouteNames.collection:
        return _pageRoute(const CollectionScreen(), settings);
      case RouteNames.companions:
        return _pageRoute(const CompanionSelectScreen(), settings);
      case RouteNames.room:
        return _pageRoute(const RoomScreen(), settings);
      case RouteNames.shop:
        return _pageRoute(const ShopScreen(), settings);
      case RouteNames.chess:
        return _pageRoute(const ChessScreen(), settings);
      case RouteNames.piano:
        return _pageRoute(const PianoScreen(), settings);
      case RouteNames.guitar:
        return _pageRoute(const GuitarScreen(), settings);
      case RouteNames.parentGate:
        return _pageRoute(const ParentGateScreen(), settings);
      case RouteNames.parentZone:
        return _pageRoute(const ParentZoneScreen(), settings);
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
