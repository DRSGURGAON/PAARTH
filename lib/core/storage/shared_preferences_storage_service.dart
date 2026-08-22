import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

/// [LocalStorageService] backed by `shared_preferences` — a flat,
/// synchronous-read key/value store that's more than enough for V1's
/// save data.
class SharedPreferencesStorageService implements LocalStorageService {
  SharedPreferences? _prefs;

  SharedPreferences get _requirePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPreferencesStorageService.init() must be awaited before use.',
      );
    }
    return prefs;
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  String? getString(String key) => _requirePrefs.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _requirePrefs.setString(key, value);

  @override
  int? getInt(String key) => _requirePrefs.getInt(key);

  @override
  Future<bool> setInt(String key, int value) =>
      _requirePrefs.setInt(key, value);

  @override
  bool? getBool(String key) => _requirePrefs.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) =>
      _requirePrefs.setBool(key, value);

  @override
  Future<bool> remove(String key) => _requirePrefs.remove(key);

  @override
  Future<bool> clearAll() => _requirePrefs.clear();
}
