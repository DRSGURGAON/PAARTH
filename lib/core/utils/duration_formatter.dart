/// Turns a play-time [Duration] into short, parent-facing text
/// ("45 min played", "2h 5m played") — used only by the Parent Zone
/// dashboard, kept standalone so its rounding rules are unit-testable
/// without pulling in any widget.
class DurationFormatter {
  DurationFormatter._();

  static String playTime(Duration duration) {
    final totalMinutes = duration.inMinutes;
    if (totalMinutes < 1) return 'Less than a minute played';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) return '$minutes min played';
    if (minutes == 0) return '${hours}h played';
    return '${hours}h ${minutes}m played';
  }
}
