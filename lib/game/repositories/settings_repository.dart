import '../../core/storage/local_storage_service.dart';

/// Parent-controlled feedback settings — sound effects and haptics,
/// both on by default. Lives in Parent Zone alongside Reset All
/// Progress, since both are "grown-up" controls over the child's
/// experience rather than gameplay state.
class SettingsRepository {
  SettingsRepository(this._storage);

  final LocalStorageService _storage;

  static const String _soundEnabledKey = 'settings_sound_enabled_v1';
  static const String _hapticsEnabledKey = 'settings_haptics_enabled_v1';

  bool get soundEnabled => _storage.getBool(_soundEnabledKey) ?? true;
  bool get hapticsEnabled => _storage.getBool(_hapticsEnabledKey) ?? true;

  Future<void> setSoundEnabled(bool enabled) {
    return _storage.setBool(_soundEnabledKey, enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) {
    return _storage.setBool(_hapticsEnabledKey, enabled);
  }
}
