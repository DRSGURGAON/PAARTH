/// A "grown-ups only" arithmetic check for the Parent Zone gate
/// (design brief section: "Parent Zone" — a simple gate, replaceable
/// with something stronger later). The operand ranges are picked to
/// sit well beyond Class 2 / age ~7 mental math, without being hard
/// for an adult.
class ParentGateChallenge {
  const ParentGateChallenge({required this.a, required this.b});

  final int a;
  final int b;

  int get answer => a * b;
  String get prompt => '$a × $b';
}
