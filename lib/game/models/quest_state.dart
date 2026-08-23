/// A quest's lifecycle on any given screen. Never stored as a value —
/// always derived live via [resolveQuestState] from the real underlying
/// facts (location unlock, saved progress, completion set), so it can't
/// drift out of sync with them.
enum QuestState { locked, available, inProgress, completed }

QuestState resolveQuestState({
  required String questId,
  required bool locationUnlocked,
  required Set<String> completedQuestIds,
  required String? inProgressQuestId,
}) {
  if (completedQuestIds.contains(questId)) return QuestState.completed;
  if (!locationUnlocked) return QuestState.locked;
  if (inProgressQuestId == questId) return QuestState.inProgress;
  return QuestState.available;
}
