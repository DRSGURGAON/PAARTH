import '../../core/storage/local_storage_service.dart';

/// The child's coin balance — a separate currency from stars (brief
/// section 11). Stars gate map progression; coins are the shop
/// currency for cosmetics (Phase 9's character customization / room
/// decoration purchases spend from this balance).
class CoinRepository {
  CoinRepository(this._storage);

  final LocalStorageService _storage;

  static const String _coinsKey = 'progress_coins_v1';

  int get coins => _storage.getInt(_coinsKey) ?? 0;

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _storage.setInt(_coinsKey, coins + amount);
  }

  /// Spends [amount] if the balance covers it, returning whether the
  /// spend happened. Never leaves the balance negative — a spend that
  /// can't be covered is simply refused, not partially applied.
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    if (coins < amount) return false;
    await _storage.setInt(_coinsKey, coins - amount);
    return true;
  }
}
