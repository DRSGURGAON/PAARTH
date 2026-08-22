import '../../core/storage/local_storage_service.dart';

/// The child's cumulative in-app time, for the Parent Zone dashboard.
/// Recorded by `PlayTimeTracker` off real app-lifecycle transitions —
/// this repository only persists the running total.
class PlayTimeRepository {
  PlayTimeRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'play_time_seconds_v1';

  int get totalSeconds => _storage.getInt(_storageKey) ?? 0;

  Future<void> addSeconds(int seconds) async {
    if (seconds <= 0) return;
    await _storage.setInt(_storageKey, totalSeconds + seconds);
  }
}
