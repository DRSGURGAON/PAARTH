import 'package:flutter/material.dart';

import '../../../core/audio/feedback_service.dart';
import '../../../core/audio/instrument_sound_service.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../game/data/guitar_chords.dart';
import '../../../game/models/activity_progress.dart';
import '../../../game/repositories/activity_progress_repository.dart';
import '../../../game/repositories/coin_repository.dart';
import '../../../game/repositories/progress_repository.dart';
import '../../../game/systems/quest_reward_service.dart';
import '../../../shared/widgets/pop_in.dart';
import '../../../shared/widgets/shake_widget.dart';

/// 🎸 Super Guitar — "Play & Learn". Six real strings (tap one to pluck
/// it, Strum to sound them together), four beginner chord buttons that
/// re-tune what the strings play, and a Learn-a-Song mode that
/// highlights the next chord of a simple progression. Free play has no
/// score and no failure; first-time song completions earn a small
/// reward.
class GuitarScreen extends StatefulWidget {
  const GuitarScreen({this.soundService, super.key});

  /// Injectable sound backend for tests.
  final InstrumentSoundService? soundService;

  @override
  State<GuitarScreen> createState() => GuitarScreenState();
}

@visibleForTesting
class GuitarScreenState extends State<GuitarScreen> {
  late InstrumentSoundService _sound;
  late FeedbackService _feedbackService;
  late ActivityProgressRepository _activityRepository;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  bool _loaded = false;

  GuitarChord? _chord;
  GuitarSong? _song;
  int _songIndex = 0;
  bool _songComplete = false;
  bool _rewardPaid = false;
  String? _feedback;
  final List<int> _stringShakes = List.filled(6, 0);

  @visibleForTesting
  int get songIndex => _songIndex;

  String? get _targetChordId =>
      _song == null || _songComplete ? null : _song!.chords[_songIndex];

  /// What each string sounds right now: the selected chord's fingering,
  /// or the open strings when no chord is held.
  List<String?> get _stringNotes =>
      _chord?.strings ?? GuitarContent.openStrings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _sound = widget.soundService ?? InstrumentSoundService(storage);
    _feedbackService = FeedbackService(storage);
    _activityRepository = ActivityProgressRepository(storage);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _loaded = true;
  }

  Future<void> _selectChord(GuitarChord chord) async {
    // Learning a chord for the first time is itself a milestone.
    await _activityRepository.addAchievement(
        ActivityIds.guitar, 'chord_${chord.id}');
    if (!mounted) return;
    setState(() => _chord = chord);
    _strum();
    final target = _targetChordId;
    if (target != null) {
      if (chord.id == target) {
        final nextIndex = _songIndex + 1;
        if (nextIndex >= _song!.chords.length) {
          await _completeSong();
        } else {
          setState(() {
            _songIndex = nextIndex;
            _feedback = '✨ Great strum!';
          });
        }
      } else {
        setState(() {
          _feedback = 'No problem — try the glowing chord!';
        });
      }
    }
  }

  void _pluckString(int stringIndex) {
    final note = _stringNotes[stringIndex];
    setState(() => _stringShakes[stringIndex]++);
    if (note != null) _sound.playNote('guitar', note);
  }

  /// Strums the current chord low string to high with a real strum's
  /// slight roll (~35ms between strings) — sounds natural and avoids
  /// firing six samples in the same audio frame.
  void _strum() {
    for (var i = 0; i < 6; i++) {
      final stringIndex = i;
      if (stringIndex == 0) {
        _pluckString(stringIndex);
        continue;
      }
      Future.delayed(Duration(milliseconds: 35 * stringIndex), () {
        if (!mounted) return;
        _pluckString(stringIndex);
      });
    }
  }

  void _startSong(GuitarSong song) {
    setState(() {
      _song = song;
      _songIndex = 0;
      _songComplete = false;
      _rewardPaid = false;
      _feedback = null;
    });
  }

  void _startFreePlay() {
    setState(() {
      _song = null;
      _songComplete = false;
      _feedback = null;
    });
  }

  Future<void> _completeSong() async {
    final song = _song!;
    final newlyEarned = await _activityRepository.addAchievement(
        ActivityIds.guitar, 'song_${song.id}');
    await _activityRepository.recordSessionCompleted(ActivityIds.guitar);
    var paid = false;
    if (newlyEarned) {
      const reward = QuestRewardService.songCompletionReward;
      await _progressRepository.addStars(reward.stars);
      await _coinRepository.addCoins(reward.coins);
      paid = true;
    }
    if (!mounted) return;
    _feedbackService.play(SoundEvent.reward);
    setState(() {
      _songComplete = true;
      _rewardPaid = paid;
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Super Guitar')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('🎸 Play & Learn', textAlign: TextAlign.center,
                  style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('guitar_free_play'),
                      onPressed: _startFreePlay,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            _song == null ? AppColors.grapePurple : Colors.white,
                        foregroundColor:
                            _song == null ? Colors.white : AppColors.inkNavy,
                      ),
                      child: const Text('Free Play'),
                    ),
                  ),
                  for (final song in GuitarContent.songs) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        key: ValueKey('guitar_song_${song.id}'),
                        onPressed: () => _startSong(song),
                        style: FilledButton.styleFrom(
                          backgroundColor: _song?.id == song.id
                              ? AppColors.grapePurple
                              : Colors.white,
                          foregroundColor: _song?.id == song.id
                              ? Colors.white
                              : AppColors.inkNavy,
                        ),
                        child: Text(song.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: Center(child: _buildModeBanner(textTheme)),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildStrings()),
              const SizedBox(height: 8),
              _buildChordRow(),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const ValueKey('guitar_strum'),
                onPressed: _strum,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.waves_rounded),
                label: Text(
                    'Strum${_chord == null ? '' : ' ${_chord!.label}'}!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeBanner(TextTheme textTheme) {
    if (_songComplete) {
      return PopIn(
        child: Text(
          _rewardPaid
              ? '🎉 Song complete! +'
                  '${QuestRewardService.songCompletionReward.stars} ⭐  +'
                  '${QuestRewardService.songCompletionReward.coins} 🪙'
              : '🎉 Song complete! Rock on!',
          key: const ValueKey('guitar_song_complete'),
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
      );
    }
    if (_song != null) {
      final label = GuitarContent.chordById(_targetChordId!).label;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chord ${_songIndex + 1} of ${_song!.chords.length} — '
            'tap the glowing chord: $label',
            key: const ValueKey('guitar_song_progress'),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          if (_feedback != null)
            Text(_feedback!,
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.gentleWarning)),
        ],
      );
    }
    return Text('Tap a string or strum — make some noise!',
        textAlign: TextAlign.center, style: textTheme.titleMedium);
  }

  Widget _buildStrings() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB5793B), Color(0xFF8A5527)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          for (var i = 5; i >= 0; i--)
            Expanded(child: _buildString(i)),
        ],
      ),
    );
  }

  Widget _buildString(int stringIndex) {
    final note = _stringNotes[stringIndex];
    final muted = note == null;
    // Lower strings draw thicker, like a real guitar.
    final thickness = 5.0 - stringIndex * 0.6;
    return Semantics(
      button: true,
      label: muted
          ? 'String ${stringIndex + 1}, muted in this chord'
          : 'Guitar string ${stringIndex + 1}',
      child: GestureDetector(
        key: ValueKey('guitar_string_$stringIndex'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _pluckString(stringIndex),
        child: Center(
          child: ShakeWidget(
            shakeSignal: _stringShakes[stringIndex],
            child: Container(
              height: thickness.clamp(2.0, 6.0),
              decoration: BoxDecoration(
                color: muted
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFFF2E3B3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChordRow() {
    return Row(
      children: [
        for (final chord in GuitarContent.chords) ...[
          Expanded(
            child: FilledButton(
              key: ValueKey('guitar_chord_${chord.id}'),
              onPressed: () => _selectChord(chord),
              style: FilledButton.styleFrom(
                backgroundColor: _targetChordId == chord.id
                    ? AppColors.sunshineYellow
                    : _chord?.id == chord.id
                        ? AppColors.grapePurple
                        : Colors.white,
                foregroundColor: _chord?.id == chord.id
                    ? Colors.white
                    : AppColors.inkNavy,
              ),
              child: Text(chord.label),
            ),
          ),
          if (chord != GuitarContent.chords.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
