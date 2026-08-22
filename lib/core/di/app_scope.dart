import 'package:flutter/widgets.dart';

import '../storage/local_storage_service.dart';

/// Minimal dependency-injection point: hands already-initialized core
/// services down the widget tree without pulling in a state-management
/// package for something this small. Later phases (audio manager,
/// save-game repository, difficulty tracker, ...) add fields here rather
/// than each screen constructing its own singleton.
class AppScope extends InheritedWidget {
  const AppScope({
    required this.storage,
    required super.child,
    super.key,
  });

  final LocalStorageService storage;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope.of() called with no AppScope in tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => storage != oldWidget.storage;
}
