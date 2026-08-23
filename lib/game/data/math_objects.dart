/// One countable object used in Math Dash visuals ("5 apples + 3
/// apples" instead of bare digits).
class MathObject {
  const MathObject({required this.id, required this.label, required this.emoji});

  final String id;
  final String label;
  final String emoji;
}

/// The visual-object catalog (brief section 6). Emoji are the honest
/// stand-in for real vector art — no production assets exist in this
/// repo yet (see the README's Assets section), and every object lives
/// here so swapping in real graphics later touches one file. New
/// objects can be appended freely; the generator picks from this list.
class MathObjects {
  MathObjects._();

  static const List<MathObject> all = [
    MathObject(id: 'banana', label: 'banana', emoji: '🍌'),
    MathObject(id: 'apple', label: 'apple', emoji: '🍎'),
    MathObject(id: 'star', label: 'star', emoji: '⭐'),
    MathObject(id: 'strawberry', label: 'strawberry', emoji: '🍓'),
    MathObject(id: 'coin', label: 'coin', emoji: '🪙'),
  ];
}
