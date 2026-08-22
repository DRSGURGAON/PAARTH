/// Central registry of route names, so screens never hard-code path
/// strings and new routes are added in exactly one place.
class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String welcome = '/welcome';

  // Registered here ahead of time so `AppRouter` has real destinations to
  // point at; the screens themselves are honest "arriving in Phase N"
  // placeholders until their phase lands.
  static const String heroSelection = '/hero-selection';
}
