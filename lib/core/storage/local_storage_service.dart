/// Abstraction over "some key/value place to persist small bits of game
/// state locally." Game and feature code should depend on this interface,
/// never on `SharedPreferences` directly — that keeps the door open for
/// swapping the backing store (e.g. to a structured DB, or adding cloud
/// sync in Phase 11+) without touching call sites.
abstract class LocalStorageService {
  /// Must be called once before first read/write (e.g. in `main()`).
  Future<void> init();

  String? getString(String key);
  Future<bool> setString(String key, String value);

  int? getInt(String key);
  Future<bool> setInt(String key, int value);

  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);

  Future<bool> remove(String key);

  /// Wipes every key this service manages — the Parent Zone "Reset All
  /// Progress" action's only real dependency. Deliberately blunt (no
  /// per-key allowlist to keep in sync) rather than a curated key list
  /// that would silently miss whatever the next phase adds.
  Future<bool> clearAll();
}
