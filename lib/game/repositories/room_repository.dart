import 'dart:convert';

import '../../core/storage/local_storage_service.dart';
import '../models/room_profile.dart';
import '../models/shop_item.dart';

/// Loads/saves the child's [RoomProfile] and equips/clears one slot at
/// a time — the shape the Player Room screen actually needs, so
/// callers never have to hand-assemble a full profile just to change
/// one decoration.
class RoomRepository {
  RoomRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'room_profile_v1';

  RoomProfile load() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return const RoomProfile.empty();

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return RoomProfile.fromJson(decoded);
    } on FormatException {
      return const RoomProfile.empty();
    }
  }

  /// Equips [itemId] in [slot], or clears that slot when [itemId] is
  /// null. Only room categories (wallArt/rug/plant/lamp) are valid
  /// slots; hero categories have no room slot to equip into.
  Future<void> setSlot(ShopCategory slot, String? itemId) {
    final current = load();
    final updated = switch (slot) {
      ShopCategory.wallArt => RoomProfile(
          wallArtItemId: itemId,
          rugItemId: current.rugItemId,
          plantItemId: current.plantItemId,
          lampItemId: current.lampItemId,
        ),
      ShopCategory.rug => RoomProfile(
          wallArtItemId: current.wallArtItemId,
          rugItemId: itemId,
          plantItemId: current.plantItemId,
          lampItemId: current.lampItemId,
        ),
      ShopCategory.plant => RoomProfile(
          wallArtItemId: current.wallArtItemId,
          rugItemId: current.rugItemId,
          plantItemId: itemId,
          lampItemId: current.lampItemId,
        ),
      ShopCategory.lamp => RoomProfile(
          wallArtItemId: current.wallArtItemId,
          rugItemId: current.rugItemId,
          plantItemId: current.plantItemId,
          lampItemId: itemId,
        ),
      ShopCategory.hair ||
      ShopCategory.outfit ||
      ShopCategory.shoes ||
      ShopCategory.backpack =>
        throw ArgumentError.value(slot, 'slot', 'not a room slot'),
    };

    return _storage.setString(_storageKey, jsonEncode(updated.toJson()));
  }

  String? itemIdFor(RoomProfile profile, ShopCategory slot) {
    return switch (slot) {
      ShopCategory.wallArt => profile.wallArtItemId,
      ShopCategory.rug => profile.rugItemId,
      ShopCategory.plant => profile.plantItemId,
      ShopCategory.lamp => profile.lampItemId,
      ShopCategory.hair ||
      ShopCategory.outfit ||
      ShopCategory.shoes ||
      ShopCategory.backpack =>
        throw ArgumentError.value(slot, 'slot', 'not a room slot'),
    };
  }
}
