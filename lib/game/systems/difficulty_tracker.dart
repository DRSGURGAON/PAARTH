import 'dart:convert';

import '../../core/storage/local_storage_service.dart';
import '../models/quest.dart';

/// Per-subject adaptive difficulty (design brief section 13). Each
/// [ChallengeCategory] has a level from [minLevel] to [maxLevel]:
///
/// - 3 first-try correct answers in a row → level up (streak resets)
/// - 2 first-try misses in a row → level down (gently — never a message
///   to the child, just easier questions)
///
/// Levels and streaks persist, so difficulty carries across sessions.
/// Math Dash consumes this now; Memory/Pattern/Word games (Phases 5–6)
/// record into the same tracker.
class DifficultyTracker {
  DifficultyTracker(this._storage);

  final LocalStorageService _storage;

  static const String _storageKey = 'difficulty_tracker_v1';
  static const int minLevel = 1;
  static const int maxLevel = 5;
  static const int streakToLevelUp = 3;
  static const int missesToLevelDown = 2;

  int levelFor(ChallengeCategory category) =>
      _stateFor(category).level;

  Future<void> recordResult(
    ChallengeCategory category, {
    required bool correct,
  }) async {
    final state = _stateFor(category);

    if (correct) {
      state.correctStreak++;
      state.wrongStreak = 0;
      if (state.correctStreak >= streakToLevelUp) {
        state.level = (state.level + 1).clamp(minLevel, maxLevel);
        state.correctStreak = 0;
      }
    } else {
      state.wrongStreak++;
      state.correctStreak = 0;
      if (state.wrongStreak >= missesToLevelDown) {
        state.level = (state.level - 1).clamp(minLevel, maxLevel);
        state.wrongStreak = 0;
      }
    }

    await _save(category, state);
  }

  _CategoryState _stateFor(ChallengeCategory category) {
    final all = _loadAll();
    return all[category.name] ?? _CategoryState();
  }

  Future<void> _save(ChallengeCategory category, _CategoryState state) {
    final all = _loadAll();
    all[category.name] = state;
    final encoded = jsonEncode(
      all.map((key, value) => MapEntry(key, value.toJson())),
    );
    return _storage.setString(_storageKey, encoded);
  }

  Map<String, _CategoryState> _loadAll() {
    final raw = _storage.getString(_storageKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          _CategoryState.fromJson(value as Map<String, dynamic>),
        ),
      );
    } on FormatException {
      return {};
    }
  }
}

class _CategoryState {
  _CategoryState({
    this.level = DifficultyTracker.minLevel,
    this.correctStreak = 0,
    this.wrongStreak = 0,
  });

  factory _CategoryState.fromJson(Map<String, dynamic> json) {
    return _CategoryState(
      level: (json['level'] as int? ?? DifficultyTracker.minLevel)
          .clamp(DifficultyTracker.minLevel, DifficultyTracker.maxLevel),
      correctStreak: json['correctStreak'] as int? ?? 0,
      wrongStreak: json['wrongStreak'] as int? ?? 0,
    );
  }

  int level;
  int correctStreak;
  int wrongStreak;

  Map<String, dynamic> toJson() => {
        'level': level,
        'correctStreak': correctStreak,
        'wrongStreak': wrongStreak,
      };
}
