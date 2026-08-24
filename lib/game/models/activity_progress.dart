/// Canonical dashboard-activity ids.
class ActivityIds {
  ActivityIds._();

  static const String chess = 'chess';
  static const String piano = 'piano';
  static const String guitar = 'guitar';
}

/// Progress for one dashboard activity (brief section 29): a reusable
/// shape that future activities (Drawing, Science Lab, ...) can adopt
/// without changing the dashboard architecture.
class ActivityProgress {
  const ActivityProgress({
    required this.activityId,
    this.sessionsCompleted = 0,
    this.achievements = const {},
    this.skillLevel = 1,
  });

  factory ActivityProgress.fromJson(String activityId, Map<String, dynamic> json) {
    return ActivityProgress(
      activityId: activityId,
      sessionsCompleted: (json['sessionsCompleted'] as num?)?.toInt() ?? 0,
      achievements: ((json['achievements'] as List?) ?? const [])
          .whereType<String>()
          .toSet(),
      skillLevel: (json['skillLevel'] as num?)?.toInt() ?? 1,
    );
  }

  final String activityId;

  /// Finished sessions — chess matches played, songs completed, ...
  final int sessionsCompleted;

  /// Milestone ids ('chess_first_win', 'song_twinkle', 'chord_c', ...).
  final Set<String> achievements;

  /// Activity-specific level — chess uses it as preferred AI difficulty.
  final int skillLevel;

  ActivityProgress copyWith({
    int? sessionsCompleted,
    Set<String>? achievements,
    int? skillLevel,
  }) {
    return ActivityProgress(
      activityId: activityId,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      achievements: achievements ?? this.achievements,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionsCompleted': sessionsCompleted,
        'achievements': achievements.toList(),
        'skillLevel': skillLevel,
      };
}
