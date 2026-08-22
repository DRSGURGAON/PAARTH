import '../../core/storage/local_storage_service.dart';

/// The child's cross-world progress currency. Only stars exist in Phase
/// 2 (the Adventure Map needs them to decide what's unlocked); coins,
/// badges and the rest of Phase 7's reward system extend this later.
///
/// Nothing calls [addStars] yet — there is no quest system to earn stars
/// from until Phase 3 — but the read path the map depends on is real,
/// not a stub, and Phase 3 plugs into this exact method.
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
