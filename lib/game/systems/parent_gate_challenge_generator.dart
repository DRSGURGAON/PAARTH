import 'dart:math';

import '../models/parent_gate_challenge.dart';

/// Generates the Parent Zone gate's multiplication challenge:
/// a two-digit number (12–20) times a single digit (4–9), so the
/// product is always well outside what a Class 2 / age ~7 child does
/// mentally, while staying a quick sum for an adult.
class ParentGateChallengeGenerator {
  ParentGateChallengeGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  ParentGateChallenge next() {
    final a = 12 + _random.nextInt(9); // 12..20
    final b = 4 + _random.nextInt(6); // 4..9
    return ParentGateChallenge(a: a, b: b);
  }
}
