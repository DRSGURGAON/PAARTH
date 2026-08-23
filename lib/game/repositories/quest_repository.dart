import 'dart:convert';

import '../../core/storage/local_storage_service.dart';

/// Persists which quests the child has completed (a JSON list of quest
/// ids) and how many stars each first clear actually paid out (a JSON
/// map — a perfect run earns more than the quest's base reward, and the
/// map's "✓ N ⭐ earned" caption should show the real number).
/// Completion gates one-time rewards (see [QuestEngine]) and Parent
/// Zone progress reporting.
class QuestRepository {
  QuestRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'completed_quests_v1';
  static const String _starsKey = 'quest_stars_v1';

  Set<String> completedQuestIds() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return <String>{};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<String>().toSet();
    } on FormatException {
      return <String>{};
    }
  }

  bool isCompleted(String questId) => completedQuestIds().contains(questId);

  /// Stars the first clear of [questId] actually awarded, or null when
  /// unknown (never completed, or completed before this was recorded —
  /// callers fall back to the quest's base reward for those old saves).
  int? starsEarnedFor(String questId) {
    final raw = _storage.getString(_starsKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return (decoded[questId] as num?)?.toInt();
    } on FormatException {
      return null;
    }
  }

  Future<void> markCompleted(String questId, {int? starsEarned}) async {
    final ids = completedQuestIds()..add(questId);
    await _storage.setString(_storageKey, jsonEncode(ids.toList()));
    if (starsEarned == null) return;

    Map<String, dynamic> stars;
    final raw = _storage.getString(_starsKey);
    try {
      final decoded = raw == null ? null : jsonDecode(raw);
      stars = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      stars = <String, dynamic>{};
    }
    stars[questId] = starsEarned;
    await _storage.setString(_starsKey, jsonEncode(stars));
  }
}
