import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/tracking/play_time_tracker.dart';
import 'package:super_kid_adventure/game/repositories/play_time_repository.dart';

import '../support/fake_local_storage_service.dart';

/// A manually-advanced clock, so tests control elapsed time exactly
/// instead of depending on real wall-clock delays.
class _FakeClock {
  DateTime _now = DateTime(2026, 1, 1);

  DateTime call() => _now;

  void advance(Duration duration) => _now = _now.add(duration);
}

void main() {
  Future<PlayTimeTrackerState> pumpTracker(
    WidgetTester tester,
    FakeLocalStorageService storage,
    _FakeClock clock,
  ) async {
    await tester.pumpWidget(
      AppScope(
        storage: storage,
        child: PlayTimeTracker(now: clock.call, child: const SizedBox()),
      ),
    );
    return tester.state<PlayTimeTrackerState>(find.byType(PlayTimeTracker));
  }

  testWidgets('flushes elapsed foreground time when the app pauses',
      (tester) async {
    final storage = FakeLocalStorageService();
    final clock = _FakeClock();
    final state = await pumpTracker(tester, storage, clock);

    clock.advance(const Duration(seconds: 90));
    state.didChangeAppLifecycleState(AppLifecycleState.paused);

    expect(PlayTimeRepository(storage).totalSeconds, 90);
  });

  testWidgets('time spent paused/backgrounded is never counted',
      (tester) async {
    final storage = FakeLocalStorageService();
    final clock = _FakeClock();
    final state = await pumpTracker(tester, storage, clock);

    clock.advance(const Duration(seconds: 60));
    state.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(PlayTimeRepository(storage).totalSeconds, 60);

    // A long real-world gap while backgrounded must not count.
    clock.advance(const Duration(hours: 5));
    state.didChangeAppLifecycleState(AppLifecycleState.resumed);
    clock.advance(const Duration(seconds: 30));
    state.didChangeAppLifecycleState(AppLifecycleState.paused);

    expect(PlayTimeRepository(storage).totalSeconds, 90);
  });

  testWidgets('a pause with no matching resume first is a no-op',
      (tester) async {
    final storage = FakeLocalStorageService();
    final clock = _FakeClock();
    final state = await pumpTracker(tester, storage, clock);

    clock.advance(const Duration(seconds: 10));
    state.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(PlayTimeRepository(storage).totalSeconds, 10);

    // Already flushed — a second paused event without a resume between
    // must not double-count or throw.
    clock.advance(const Duration(seconds: 999));
    state.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(PlayTimeRepository(storage).totalSeconds, 10);
  });

  testWidgets('inactive/hidden transitions do not themselves flush',
      (tester) async {
    final storage = FakeLocalStorageService();
    final clock = _FakeClock();
    final state = await pumpTracker(tester, storage, clock);

    clock.advance(const Duration(seconds: 20));
    state.didChangeAppLifecycleState(AppLifecycleState.inactive);
    state.didChangeAppLifecycleState(AppLifecycleState.hidden);
    expect(PlayTimeRepository(storage).totalSeconds, 0);

    clock.advance(const Duration(seconds: 5));
    state.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(PlayTimeRepository(storage).totalSeconds, 25);
  });

  testWidgets('disposing the tracker flushes any still-running session',
      (tester) async {
    final storage = FakeLocalStorageService();
    final clock = _FakeClock();
    await pumpTracker(tester, storage, clock);

    clock.advance(const Duration(seconds: 45));
    await tester.pumpWidget(const SizedBox()); // Tears down the tracker.

    expect(PlayTimeRepository(storage).totalSeconds, 45);
  });
}
