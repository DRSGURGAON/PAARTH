import 'dart:convert';

import '../../core/storage/local_storage_service.dart';

/// Persists which quests the child has completed, as a JSON list of
/// quest ids. Completion is what gates one-time star rewards (see
/// [QuestEngine]) and, later, Parent Zone progress reporting.
class QuestRepository {
  QuestRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'completed_quests_v1';

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

  Future<void> markCompleted(String questId) {
    final ids = completedQuestIds()..add(questId);
    return _storage.setString(_storageKey, jsonEncode(ids.toList()));
  }
}
