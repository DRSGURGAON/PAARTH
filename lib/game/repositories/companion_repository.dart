import '../../core/storage/local_storage_service.dart';

/// Tracks which single companion the child has equipped as their active
/// helper. Whether a companion is *unlocked* is a derived fact computed
/// from mini-game progress (see `CompanionCatalog.unlockedCompanionIds`)
/// — this repository only stores the equipped choice, same shape as
/// `HeroRepository`'s single saved profile.
class CompanionRepository {
  CompanionRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'selected_companion_v1';

  String? get selectedCompanionId => _storage.getString(_storageKey);

  Future<void> selectCompanion(String companionId) {
    return _storage.setString(_storageKey, companionId);
  }
}
