/// Central registry of route names, so screens never hard-code path
/// strings and new routes are added in exactly one place.
class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String heroSelection = '/hero-selection';
  static const String home = '/home';
  static const String adventureMap = '/adventure-map';
  static const String miniGames = '/mini-games';
  static const String collection = '/collection';
}
