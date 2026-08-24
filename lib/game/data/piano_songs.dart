/// One key on the Super Piano keyboard (one octave, C4–C5).
class PianoKey {
  const PianoKey({required this.noteId, required this.label, required this.isBlack});

  /// Matches the bundled sample filename (assets/audio/piano/<id>.wav).
  final String noteId;
  final String label;
  final bool isBlack;
}

/// A simple guided melody for Song Mode: an ordered list of note ids
/// the child taps one at a time.
class PianoSong {
  const PianoSong({required this.id, required this.title, required this.notes});

  final String id;
  final String title;
  final List<String> notes;
}

/// Super Piano content. The keyboard is one octave plus the top C —
/// enough for real simple melodies without overwhelming a small phone
/// screen. Song note sequences are our own encodings: "Twinkle" is a
/// public-domain melody, "The Jungle Song" is original — no copyrighted
/// recordings or arrangements anywhere (all audio is synthesized in
/// this repo).
class PianoContent {
  PianoContent._();

  static const List<PianoKey> whiteKeys = [
    PianoKey(noteId: 'c4', label: 'C', isBlack: false),
    PianoKey(noteId: 'd4', label: 'D', isBlack: false),
    PianoKey(noteId: 'e4', label: 'E', isBlack: false),
    PianoKey(noteId: 'f4', label: 'F', isBlack: false),
    PianoKey(noteId: 'g4', label: 'G', isBlack: false),
    PianoKey(noteId: 'a4', label: 'A', isBlack: false),
    PianoKey(noteId: 'b4', label: 'B', isBlack: false),
    PianoKey(noteId: 'c5', label: 'C', isBlack: false),
  ];

  /// Black keys with the index of the white key each sits after —
  /// C#/D# between C-D-E, F#/G#/A# between F-G-A-B.
  static const List<(PianoKey, int)> blackKeys = [
    (PianoKey(noteId: 'cs4', label: 'C#', isBlack: true), 0),
    (PianoKey(noteId: 'ds4', label: 'D#', isBlack: true), 1),
    (PianoKey(noteId: 'fs4', label: 'F#', isBlack: true), 3),
    (PianoKey(noteId: 'gs4', label: 'G#', isBlack: true), 4),
    (PianoKey(noteId: 'as4', label: 'A#', isBlack: true), 5),
  ];

  static const List<PianoSong> songs = [
    PianoSong(
      id: 'twinkle',
      title: 'Twinkle Twinkle',
      notes: [
        'c4', 'c4', 'g4', 'g4', 'a4', 'a4', 'g4',
        'f4', 'f4', 'e4', 'e4', 'd4', 'd4', 'c4',
      ],
    ),
    PianoSong(
      id: 'jungle_song',
      title: 'The Jungle Song',
      notes: [
        'c4', 'e4', 'g4', 'e4', 'c4', 'e4', 'g4', 'c5',
        'b4', 'g4', 'e4', 'c4',
      ],
    ),
  ];
}
