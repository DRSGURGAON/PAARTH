/// App-wide constant values that don't belong to a specific feature.
class AppConstants {
  AppConstants._();

  static const String appName = 'Super Kid Adventure';
  static const String appTagline = 'Play. Learn. Explore. Become a Super Kid!';

  /// Minimum size for any tappable control, so small hands on small
  /// screens can reliably hit it.
  static const double minTouchTargetSize = 56.0;

  static const Duration splashMinDuration = Duration(seconds: 2);
}
