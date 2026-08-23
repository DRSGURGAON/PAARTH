/// One rememberable jungle friend (or object) in Memory Master.
class MemoryObject {
  const MemoryObject({required this.id, required this.label, required this.emoji});

  final String id;
  final String label;
  final String emoji;
}

/// One named place in the jungle scene where an object can appear —
/// "the monkey was by the tree" — so position recall is about places a
/// child can picture, not abstract slot numbers.
class JungleSpot {
  const JungleSpot({required this.id, required this.label, required this.emoji});

  final String id;
  final String label;
  final String emoji;
}

/// Memory Master's jungle content (brief section 16) — friendly
/// original characters plus environmental spots, all defined once.
/// Emoji are the honest stand-in for real vector art (none exists in
/// this repo yet — see the README's Assets section); swapping in real
/// graphics later touches this one file.
class MemoryObjects {
  MemoryObjects._();

  static const List<MemoryObject> animals = [
    MemoryObject(id: 'monkey', label: 'monkey', emoji: '🐒'),
    MemoryObject(id: 'panda', label: 'panda', emoji: '🐼'),
    MemoryObject(id: 'fox', label: 'fox', emoji: '🦊'),
    MemoryObject(id: 'rabbit', label: 'rabbit', emoji: '🐰'),
    MemoryObject(id: 'parrot', label: 'parrot', emoji: '🦜'),
    MemoryObject(id: 'frog', label: 'frog', emoji: '🐸'),
    MemoryObject(id: 'butterfly', label: 'butterfly', emoji: '🦋'),
  ];

  static const List<JungleSpot> spots = [
    JungleSpot(id: 'tree', label: 'by the tree', emoji: '🌴'),
    JungleSpot(id: 'bush', label: 'in the bush', emoji: '🌿'),
    JungleSpot(id: 'rock', label: 'on the rock', emoji: '🪨'),
    JungleSpot(id: 'waterfall', label: 'at the waterfall', emoji: '💧'),
    JungleSpot(id: 'flower', label: 'by the flower', emoji: '🌸'),
    JungleSpot(id: 'leaves', label: 'in the leaves', emoji: '🍃'),
    JungleSpot(id: 'chest', label: 'by the treasure chest', emoji: '🧰'),
  ];
}
