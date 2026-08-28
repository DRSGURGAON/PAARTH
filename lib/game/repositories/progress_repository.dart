import '../../core/storage/local_storage_service.dart';

/// The child's cross-world progress currency: total stars. Quests and
/// mini-game sessions pay in through [addStars]; the world-select and
/// map screens read [stars] to decide what's unlocked. Coins live in
/// `CoinRepository`, badges derive from real progress in
/// `BadgeCatalog` — this stays the one source of truth for stars.
class ProgressRepository {
  ProgressRepository(this._storage);

  final LocalStorageService _storage;

  static const String _starsKey = 'progress_stars_v1';

  int get stars => _storage.getInt(_starsKey) ?? 0;

  Future<void> addStars(int amount) async {
    if (amount <= 0) return;
    await _storage.setInt(_starsKey, stars + amount);
  }
}
