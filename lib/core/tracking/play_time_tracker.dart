import 'package:flutter/widgets.dart';

import '../../game/repositories/play_time_repository.dart';
import '../di/app_scope.dart';

/// Wraps the app and records real foreground play time for the Parent
/// Zone dashboard, by timestamping app-lifecycle resume/pause
/// transitions rather than a periodic timer — nothing is left pending
/// if the tree is torn down mid-session (including in widget tests).
class PlayTimeTracker extends StatefulWidget {
  const PlayTimeTracker({required this.child, this.now, super.key});

  final Widget child;

  /// Injectable clock so tests can control elapsed time deterministically
  /// instead of depending on real wall-clock delays.
  final DateTime Function()? now;

  @override
  State<PlayTimeTracker> createState() => PlayTimeTrackerState();
}

@visibleForTesting
class PlayTimeTrackerState extends State<PlayTimeTracker>
    with WidgetsBindingObserver {
  late final DateTime Function() _now = widget.now ?? DateTime.now;
  late PlayTimeRepository _repository;
  bool _loaded = false;
  DateTime? _resumedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resumedAt = _now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _repository = PlayTimeRepository(AppScope.of(context).storage);
    _loaded = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _flush();
        break;
      case AppLifecycleState.resumed:
        _resumedAt = _now();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _flush() {
    final resumedAt = _resumedAt;
    if (resumedAt == null || !_loaded) return;
    _resumedAt = null;
    final elapsed = _now().difference(resumedAt).inSeconds;
    if (elapsed > 0) _repository.addSeconds(elapsed);
  }

  @override
  void dispose() {
    _flush();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
