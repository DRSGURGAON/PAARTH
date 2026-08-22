import 'dart:convert';

import '../../core/storage/local_storage_service.dart';
import '../models/hero_profile.dart';

/// Loads/saves the child's [HeroProfile] through [LocalStorageService].
/// Screens depend on this, never on the storage service directly, so the
/// save format can evolve without touching UI code.
class HeroRepository {
  HeroRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'hero_profile_v1';

  /// Whether a hero has ever been saved — distinct from [load], which
  /// always returns a usable profile (falling back to
  /// [HeroProfile.initial] for a first-time player). Welcome uses this
  /// to decide between "PLAY" (build a hero) and "Continue Adventure"
  /// (skip straight back in).
  bool get hasSavedProfile => _storage.getString(_storageKey) != null;

  HeroProfile load() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return HeroProfile.initial();

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return HeroProfile.fromJson(decoded);
    } on FormatException {
      return HeroProfile.initial();
    }
  }

  Future<void> save(HeroProfile profile) {
    return _storage.setString(_storageKey, jsonEncode(profile.toJson()));
  }
}
