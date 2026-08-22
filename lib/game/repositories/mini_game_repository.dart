import 'dart:convert';

import '../../core/storage/local_storage_service.dart';

/// Canonical mini-game ids, shared between the screens that record a
/// star and the badge catalog that reads them back.
class MiniGameIds {
  MiniGameIds._();

  static const String mathDash = 'math_dash';
  static const String memoryMaster = 'memory_master';
  static const String patternPower = 'pattern_power';
  static const String wordBuilder = 'word_builder';
  static const String findDiscover = 'find_discover';

  static const List<String> all = [
    mathDash,
    memoryMaster,
    patternPower,
    wordBuilder,
    findDiscover,
  ];
}

/// Tracks which mini-games the child has earned a star in at least
/// once. Purely additive bookkeeping — mini-game screens themselves
/// don't read this, only the badge catalog does.
class MiniGameRepository {
  MiniGameRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'mini_game_stars_v1';

  Set<String> starEarnedGameIds() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return <String>{};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<String>().toSet();
    } on FormatException {
      return <String>{};
    }
  }

  Future<void> markStarEarned(String gameId) {
    final ids = starEarnedGameIds()..add(gameId);
    return _storage.setString(_storageKey, jsonEncode(ids.toList()));
  }
}
