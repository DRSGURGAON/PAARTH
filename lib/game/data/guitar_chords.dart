/// One guitar chord: a label plus, for each of the 6 strings (low E
/// first), the note sample it sounds — or null for a muted string.
/// Note ids match the bundled samples (assets/audio/guitar/<id>.wav).
class GuitarChord {
  const GuitarChord({required this.id, required this.label, required this.strings});

  final String id;
  final String label;
  final List<String?> strings;
}

/// A simple chord progression for Song Mode.
class GuitarSong {
  const GuitarSong({required this.id, required this.title, required this.chords});

  final String id;
  final String title;

  /// Chord ids, in play order.
  final List<String> chords;
}

/// Super Guitar content: standard-tuning open strings plus the four
/// beginner chords from the brief (C, G, Am, F — F simplified to its
/// common small shape). All audio is synthesized plucked-string tone
/// generated in this repo; nothing recorded or copyrighted.
class GuitarContent {
  GuitarContent._();

  static const List<String> openStrings = ['e2', 'a2', 'd3', 'g3', 'b3', 'e4'];

  static const List<GuitarChord> chords = [
    GuitarChord(
      id: 'c',
      label: 'C',
      strings: [null, 'c3', 'e3', 'g3', 'c4', 'e4'],
    ),
    GuitarChord(
      id: 'g',
      label: 'G',
      strings: ['g2', 'b2', 'd3', 'g3', 'b3', 'g4'],
    ),
    GuitarChord(
      id: 'am',
      label: 'Am',
      strings: [null, 'a2', 'e3', 'a3', 'c4', 'e4'],
    ),
    GuitarChord(
      id: 'f',
      label: 'F',
      strings: [null, null, 'f3', 'a3', 'c4', 'f4'],
    ),
  ];

  static GuitarChord chordById(String id) =>
      chords.firstWhere((chord) => chord.id == id);

  static const List<GuitarSong> songs = [
    GuitarSong(
      id: 'campfire',
      title: 'Campfire Strums',
      chords: ['c', 'g', 'am', 'f', 'c', 'g', 'c'],
    ),
    GuitarSong(
      id: 'jungle_beat',
      title: 'Jungle Beat',
      chords: ['am', 'f', 'c', 'g'],
    ),
  ];
}
