import 'package:flutter/material.dart';

import '../../../core/audio/feedback_service.dart';
import '../../../core/audio/instrument_sound_service.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../game/data/piano_songs.dart';
import '../../../game/models/activity_progress.dart';
import '../../../game/repositories/activity_progress_repository.dart';
import '../../../game/repositories/coin_repository.dart';
import '../../../game/repositories/progress_repository.dart';
import '../../../game/systems/quest_reward_service.dart';
import '../../../shared/widgets/pop_in.dart';

/// 🎹 Super Piano — "Make Music". A one-octave keyboard that plays real
/// (synthesized in-repo) notes. Free Play is pure creativity — no
/// score, no failure. Learn a Song highlights the next key of a simple
/// melody; a wrong tap just gently points back at the glowing key.
/// First-time song completions earn a small reward; replays stay free.
class PianoScreen extends StatefulWidget {
  const PianoScreen({this.soundService, super.key});

  /// Injectable sound backend for tests.
  final InstrumentSoundService? soundService;

  @override
  State<PianoScreen> createState() => PianoScreenState();
}

@visibleForTesting
class PianoScreenState extends State<PianoScreen> {
  late InstrumentSoundService _sound;
  late FeedbackService _feedbackService;
  late ActivityProgressRepository _activityRepository;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  bool _loaded = false;

  PianoSong? _song;
  int _songIndex = 0;
  bool _songComplete = false;
  bool _rewardPaid = false;
  String? _feedback;
  final Set<String> _pressed = {};

  @visibleForTesting
  int get songIndex => _songIndex;

  /// The key Song Mode wants next, or null in Free Play / when done.
  String? get _targetNote =>
      _song == null || _songComplete ? null : _song!.notes[_songIndex];

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

  void _startSong(PianoSong song) {
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

  Future<void> _onKeyTap(String noteId) async {
    _sound.playNote('piano', noteId);

    final target = _targetNote;
    if (target == null) return; // Free play — every note is right.

    if (noteId == target) {
      final nextIndex = _songIndex + 1;
      if (nextIndex >= _song!.notes.length) {
        await _completeSong();
      } else {
        setState(() {
          _songIndex = nextIndex;
          _feedback = '✨ Great!';
        });
      }
    } else {
      setState(() {
        _feedback = 'No problem — try the glowing key!';
      });
    }
  }

  Future<void> _completeSong() async {
    final song = _song!;
    final newlyEarned = await _activityRepository.addAchievement(
        ActivityIds.piano, 'song_${song.id}');
    await _activityRepository.recordSessionCompleted(ActivityIds.piano);
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
      appBar: AppBar(title: const Text('Super Piano')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('🎹 Make Music', textAlign: TextAlign.center,
                  style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('piano_free_play'),
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
                  for (final song in PianoContent.songs) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        key: ValueKey('piano_song_${song.id}'),
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
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: Center(child: _buildModeBanner(textTheme)),
              ),
              const Spacer(),
              _buildKeyboard(),
              const Spacer(),
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
              : '🎉 Song complete! Wonderful playing!',
          key: const ValueKey('piano_song_complete'),
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
      );
    }
    if (_song != null) {
      final label = PianoContent.whiteKeys
          .followedBy(PianoContent.blackKeys.map((b) => b.$1))
          .firstWhere((k) => k.noteId == _targetNote)
          .label;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Note ${_songIndex + 1} of ${_song!.notes.length} — '
            'tap the glowing key: $label',
            key: const ValueKey('piano_song_progress'),
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
    return Text('Tap any keys — make your own music!',
        textAlign: TextAlign.center, style: textTheme.titleMedium);
  }

  Widget _buildKeyboard() {
    return SizedBox(
      height: 220,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final whiteWidth =
              constraints.maxWidth / PianoContent.whiteKeys.length;
          return Stack(
            children: [
              Row(
                children: [
                  for (final key in PianoContent.whiteKeys)
                    Expanded(child: _buildWhiteKey(key)),
                ],
              ),
              for (final (key, afterWhite) in PianoContent.blackKeys)
                Positioned(
                  left: whiteWidth * (afterWhite + 1) - whiteWidth * 0.3,
                  width: whiteWidth * 0.6,
                  top: 0,
                  height: 120,
                  child: _buildBlackKey(key),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWhiteKey(PianoKey key) {
    final isTarget = _targetNote == key.noteId;
    final isPressed = _pressed.contains(key.noteId);
    return Semantics(
      button: true,
      label: 'Piano key ${key.label}',
      child: GestureDetector(
        key: ValueKey('piano_key_${key.noteId}'),
        onTapDown: (_) => setState(() => _pressed.add(key.noteId)),
        onTapUp: (_) => setState(() => _pressed.remove(key.noteId)),
        onTapCancel: () => setState(() => _pressed.remove(key.noteId)),
        onTap: () => _onKeyTap(key.noteId),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isPressed
                ? AppColors.sunshineYellow
                : isTarget
                    ? const Color(0xFFFFF3C0)
                    : Colors.white,
            border: Border.all(
              color: isTarget ? AppColors.sunshineYellow : AppColors.inkNavy,
              width: isTarget ? 3 : 1,
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(key.label),
        ),
      ),
    );
  }

  Widget _buildBlackKey(PianoKey key) {
    final isTarget = _targetNote == key.noteId;
    final isPressed = _pressed.contains(key.noteId);
    return Semantics(
      button: true,
      label: 'Piano key ${key.label}',
      child: GestureDetector(
        key: ValueKey('piano_key_${key.noteId}'),
        onTapDown: (_) => setState(() => _pressed.add(key.noteId)),
        onTapUp: (_) => setState(() => _pressed.remove(key.noteId)),
        onTapCancel: () => setState(() => _pressed.remove(key.noteId)),
        onTap: () => _onKeyTap(key.noteId),
        child: Container(
          decoration: BoxDecoration(
            color: isPressed
                ? AppColors.grapePurple
                : isTarget
                    ? AppColors.sunshineYellow
                    : AppColors.inkNavy,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(6)),
          ),
        ),
      ),
    );
  }
}
