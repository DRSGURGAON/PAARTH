import 'dart:convert';

import '../../core/storage/local_storage_service.dart';

/// Tracks which shop item ids the child has bought. Purchasing itself
/// (spending coins) is handled by the caller via `CoinRepository.
/// spendCoins` — this repository only records the resulting ownership,
/// same shape as `MiniGameRepository`'s star-earned set.
class ShopRepository {
  ShopRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'shop_owned_items_v1';

  Set<String> ownedItemIds() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return <String>{};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<String>().toSet();
    } on FormatException {
      return <String>{};
    }
  }

  Future<void> markOwned(String itemId) {
    final ids = ownedItemIds()..add(itemId);
    return _storage.setString(_storageKey, jsonEncode(ids.toList()));
  }
}
