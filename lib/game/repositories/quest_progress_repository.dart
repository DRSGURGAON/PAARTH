import 'dart:convert';

import '../../core/storage/local_storage_service.dart';

/// A snapshot of one in-flight quest run: which quest, which challenge
/// the child is on, and how many misses so far (misses decide the
/// perfect-run reward tier, so they must survive a restart too).
class QuestProgress {
  const QuestProgress({
    required this.questId,
    required this.challengeIndex,
    required this.wrongAttempts,
  });

  final String questId;
  final int challengeIndex;
  final int wrongAttempts;
}

/// Persists the single in-progress quest run, so closing the app
/// mid-quest resumes at the start of the current challenge instead of
/// losing everything (brief section 20). One slot is enough: the child
/// can only be inside one quest at a time, and starting a different
/// quest simply claims the slot.
class QuestProgressRepository {
  QuestProgressRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'quest_progress_v1';

  QuestProgress? load() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final questId = decoded['questId'];
      if (questId is! String) return null;
      return QuestProgress(
        questId: questId,
        challengeIndex: (decoded['challengeIndex'] as num?)?.toInt() ?? 0,
        wrongAttempts: (decoded['wrongAttempts'] as num?)?.toInt() ?? 0,
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> save(QuestProgress progress) {
    return _storage.setString(
      _storageKey,
      jsonEncode({
        'questId': progress.questId,
        'challengeIndex': progress.challengeIndex,
        'wrongAttempts': progress.wrongAttempts,
      }),
    );
  }

  Future<void> clear() => _storage.remove(_storageKey);
}
