import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/audio/feedback_service.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../game/chess/chess_ai.dart';
import '../../../game/chess/chess_game.dart';
import '../../../game/chess/chess_models.dart';
import '../../../game/models/activity_progress.dart';
import '../../../game/repositories/activity_progress_repository.dart';
import '../../../game/repositories/coin_repository.dart';
import '../../../game/repositories/progress_repository.dart';
import '../../../game/systems/quest_reward_service.dart';
import '../../../shared/widgets/big_rounded_button.dart';
import 'chess_board_view.dart';

/// A real chess match against the child-level AI: tap a piece to see
/// its legal moves highlighted, tap a highlight to play. Generous free
/// hints, undo (your move plus the AI's reply), restart, and gentle
/// end-of-game rewards — a finished match always pays something,
/// because playing a whole game is the learning.
class ChessPlayScreen extends StatefulWidget {
  const ChessPlayScreen({
    required this.level,
    this.random,
    this.aiDelay,
    this.initialGame,
    super.key,
  });

  /// AI difficulty (1–3), chosen on the Chess Club hub.
  final int level;

  /// Injectable randomness for deterministic tests.
  final Random? random;

  /// Pause before the AI answers, so its reply reads as a "turn".
  final Duration? aiDelay;

  /// Test hook: start from a custom position instead of the initial
  /// setup (e.g. a mate-in-one, to exercise the game-end flow).
  final ChessGame? initialGame;

  @override
  State<ChessPlayScreen> createState() => ChessPlayScreenState();
}

@visibleForTesting
class ChessPlayScreenState extends State<ChessPlayScreen> {
  late ChessAi _ai;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  late ActivityProgressRepository _activityRepository;
  late FeedbackService _feedbackService;
  bool _loaded = false;

  late ChessGame _game = widget.initialGame ?? ChessGame();
  int? _selected;
  Set<int> _legalTargets = {};
  ChessMove? _hint;
  bool _aiThinking = false;
  int _aiToken = 0;
  bool _rewarded = false;
  MiniGameReward? _endReward;

  @visibleForTesting
  ChessGame get game => _game;

  Duration get _delay => widget.aiDelay ?? const Duration(milliseconds: 450);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _ai = ChessAi(random: widget.random);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _activityRepository = ActivityProgressRepository(storage);
    _feedbackService = FeedbackService(storage);
    _loaded = true;
  }

  bool get _gameOver =>
      _game.status == ChessStatus.checkmate ||
      _game.status == ChessStatus.stalemate ||
      _game.status == ChessStatus.draw;

  void _restart() {
    setState(() {
      _aiToken++; // Abandon any pending AI reply.
      _game = ChessGame();
      _selected = null;
      _legalTargets = {};
      _hint = null;
      _aiThinking = false;
      _rewarded = false;
      _endReward = null;
    });
  }

  void _onSquareTap(int square) {
    if (_aiThinking || _gameOver || _game.turn != PieceColor.white) return;

    if (_legalTargets.contains(square) && _selected != null) {
      final move = _game
          .legalMovesFrom(_selected!)
          .firstWhere((m) => m.to == square);
      _playPlayerMove(move);
      return;
    }

    final piece = _game.pieceAt(square);
    setState(() {
      if (piece != null && piece.color == PieceColor.white) {
        _selected = square;
        _legalTargets = _game.legalMovesFrom(square).map((m) => m.to).toSet();
      } else {
        _selected = null;
        _legalTargets = {};
      }
    });
  }

  Future<void> _playPlayerMove(ChessMove move) async {
    final captured = _game.play(move);
    _feedbackService
        .play(captured != null ? SoundEvent.reward : SoundEvent.correct);
    setState(() {
      _selected = null;
      _legalTargets = {};
      _hint = null;
    });
    if (_gameOver) {
      await _handleGameEnd();
      return;
    }
    _scheduleAiMove();
  }

  void _scheduleAiMove() {
    setState(() => _aiThinking = true);
    final token = ++_aiToken;
    Future.delayed(_delay, () async {
      if (!mounted || token != _aiToken) return;
      final move = _ai.pickMove(_game, widget.level);
      if (move != null) _game.play(move);
      setState(() => _aiThinking = false);
      if (_gameOver) await _handleGameEnd();
    });
  }

  Future<void> _handleGameEnd() async {
    if (_rewarded) return;
    _rewarded = true;
    // Checkmate: the side to move has lost. Anything else here is a draw.
    final won = _game.status == ChessStatus.checkmate &&
        _game.turn == PieceColor.black;
    final reward = QuestRewardService.calculateChessMatch(
      won: won,
      drawn: _game.status != ChessStatus.checkmate,
    );
    await _progressRepository.addStars(reward.stars);
    await _coinRepository.addCoins(reward.coins);
    await _activityRepository.recordSessionCompleted(ActivityIds.chess);
    await _activityRepository.addAchievement(
        ActivityIds.chess, 'chess_first_game');
    if (won) {
      await _activityRepository.addAchievement(
          ActivityIds.chess, 'chess_first_win');
    }
    if (!mounted) return;
    _feedbackService.play(won ? SoundEvent.reward : SoundEvent.correct);
    setState(() => _endReward = reward);
  }

  void _showHint() {
    if (_aiThinking || _gameOver || _game.turn != PieceColor.white) return;
    final suggestion = _ai.suggestMove(_game);
    if (suggestion == null) return;
    final piece = _game.pieceAt(suggestion.from);
    setState(() {
      _hint = suggestion;
      _selected = null;
      _legalTargets = {};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '💡 Try moving your ${piece?.name.toLowerCase()} to '
          '${ChessBoardView.coordinate(suggestion.to)}!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Takes back the AI's reply and the child's own last move together,
  /// so it's the child's turn again — "let me rethink that".
  void _undoLastExchange() {
    if (_aiThinking || _game.movesPlayed == 0) return;
    setState(() {
      _aiToken++;
      _game.undo();
      if (_game.turn != PieceColor.white && _game.movesPlayed > 0) {
        _game.undo();
      }
      _selected = null;
      _legalTargets = {};
      _hint = null;
      _rewarded = false;
      _endReward = null;
    });
  }

  String get _statusLine {
    if (_endReward != null) {
      final won = _game.status == ChessStatus.checkmate &&
          _game.turn == PieceColor.black;
      if (won) return '🎉 Checkmate — you win!';
      if (_game.status == ChessStatus.checkmate) {
        return 'The AI wins this one — great game!';
      }
      return "It's a draw — well played!";
    }
    if (_aiThinking) return 'The AI is thinking…';
    if (_game.status == ChessStatus.check) {
      return _game.turn == PieceColor.white
          ? 'Careful — your King is in check!'
          : 'Check!';
    }
    return _game.turn == PieceColor.white
        ? 'Your move! Tap a piece.'
        : '…';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Chess Club · Level ${widget.level}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    _statusLine,
                    key: const ValueKey('chess_status'),
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: ChessBoardView(
                    pieceAt: _game.pieceAt,
                    onTap: _onSquareTap,
                    selected: _selected,
                    legalTargets: _legalTargets,
                    hintFrom: _hint?.from,
                    hintTo: _hint?.to,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_endReward != null) ...[
                Text(
                  '+${_endReward!.stars} ⭐  +${_endReward!.coins} 🪙',
                  key: const ValueKey('chess_reward'),
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                BigRoundedButton(
                  label: 'New Game',
                  icon: Icons.replay_rounded,
                  backgroundColor: AppColors.leafGreen,
                  onPressed: _restart,
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        key: const ValueKey('chess_hint_button'),
                        onPressed: _showHint,
                        icon: const Icon(Icons.lightbulb_rounded,
                            color: AppColors.sunshineYellow),
                        label: const Text('Hint'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        key: const ValueKey('chess_undo_button'),
                        onPressed:
                            _game.movesPlayed == 0 ? null : _undoLastExchange,
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        key: const ValueKey('chess_restart_button'),
                        onPressed: _restart,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Restart'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
