import 'dart:convert';

import '../../core/storage/local_storage_service.dart';
import '../models/activity_progress.dart';

/// Persists per-activity progress (chess/piano/guitar and any future
/// activity) as one JSON map keyed by activity id. Same corruption
/// posture as every other repository: unreadable data degrades to
/// defaults instead of throwing.
class ActivityProgressRepository {
  ActivityProgressRepository(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'activity_progress_v1';

  ActivityProgress load(String activityId) {
    final all = _loadAll();
    final json = all[activityId];
    if (json is Map<String, dynamic>) {
      return ActivityProgress.fromJson(activityId, json);
    }
    return ActivityProgress(activityId: activityId);
  }

  Future<void> save(ActivityProgress progress) {
    final all = _loadAll();
    all[progress.activityId] = progress.toJson();
    return _storage.setString(_storageKey, jsonEncode(all));
  }

  Future<ActivityProgress> recordSessionCompleted(String activityId) async {
    final updated = load(activityId).copyWith(
      sessionsCompleted: load(activityId).sessionsCompleted + 1,
    );
    await save(updated);
    return updated;
  }

  /// Adds [achievementId] if new; returns true when it was newly earned
  /// (callers pay one-time rewards only on true).
  Future<bool> addAchievement(String activityId, String achievementId) async {
    final progress = load(activityId);
    if (progress.achievements.contains(achievementId)) return false;
    await save(progress.copyWith(
      achievements: {...progress.achievements, achievementId},
    ));
    return true;
  }

  Future<void> setSkillLevel(String activityId, int level) {
    return save(load(activityId).copyWith(skillLevel: level));
  }

  Map<String, dynamic> _loadAll() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}
