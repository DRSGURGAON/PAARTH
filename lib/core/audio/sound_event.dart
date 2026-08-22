/// The moments the game gives audible/haptic feedback for. Kept short
/// and meaning-based (not "click1", "click2") so call sites read as
/// intent, and so the mapping to an actual sound/haptic in
/// [FeedbackService] can change without touching any call site.
enum SoundEvent { correct, incorrect, reward, purchase }
