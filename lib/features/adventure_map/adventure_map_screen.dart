import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/hero_profile.dart';
import '../../game/models/world_location.dart';
import '../../game/quests/jungle_quests.dart';
import '../../game/repositories/hero_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/repositories/quest_repository.dart';
import '../../game/worlds/jungle_world.dart';
import '../../shared/widgets/shake_widget.dart';
import '../player/hero_avatar_preview.dart';
import '../quests/location_quests_screen.dart';

/// A location's state on the map (brief section 4): locked (with a
/// reason), unlocked (tappable), or completed (all its quests done).
/// Never stored — always recomputed live from stars and completed quest
/// ids, the same "derived, not saved" approach the badge system uses.
enum _LocationState { locked, unlocked, completed }

/// The Jungle Adventure world map: a small winding trail of location
/// nodes rather than a static list, each animating in on entry. Locked
/// nodes show what's needed to open them; unlocked nodes lead to that
/// location's quest list; completed ones show a check and stars earned.
/// The child's own hero appears as a small marker at their current
/// furthest-unlocked location.
class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _nodeAnimations;

  /// Bumped per-location to trigger [ShakeWidget]'s gentle "no" shake
  /// when a locked node is tapped (brief section 12).
  late final List<int> _lockShakeSignals =
      List.filled(JungleWorld.locations.length, 0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _nodeAnimations = List.generate(JungleWorld.locations.length, (index) {
      final start = index * 0.15;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openLocation(WorldLocation location) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LocationQuestsScreen(location: location),
      ),
    );
    // Stars may have been earned inside — refresh lock/completed states
    // and the hero marker's position on return.
    if (mounted) setState(() {});
  }

  void _showLockedHint(WorldLocation location, int stars, int index) {
    setState(() => _lockShakeSignals[index]++);
    final remaining = location.requiredStars - stars;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Earn $remaining more ⭐ to unlock ${location.name}!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = AppScope.of(context).storage;
    final stars = ProgressRepository(storage).stars;
    final heroProfile = HeroRepository(storage).load();
    final completedQuestIds = QuestRepository(storage).completedQuestIds();

    // The furthest-unlocked location is where the hero marker stands —
    // simple derived "current position," not a separately-tracked one.
    var currentIndex = 0;
    for (var i = 0; i < JungleWorld.locations.length; i++) {
      if (JungleWorld.locations[i].isUnlockedFor(stars)) currentIndex = i;
    }

    return Scaffold(
      appBar: AppBar(title: const Text(JungleWorld.worldName)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, Color(0xFFDFF3E4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Explore the jungle and unlock new areas!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < JungleWorld.locations.length; i++)
                  _buildNode(
                    context: context,
                    index: i,
                    stars: stars,
                    heroProfile: heroProfile,
                    completedQuestIds: completedQuestIds,
                    isCurrent: i == currentIndex,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNode({
    required BuildContext context,
    required int index,
    required int stars,
    required HeroProfile heroProfile,
    required Set<String> completedQuestIds,
    required bool isCurrent,
  }) {
    final location = JungleWorld.locations[index];
    final locationQuests = JungleQuests.forLocation(location.id);
    final isUnlocked = location.isUnlockedFor(stars);
    final isCompleted = locationQuests.isNotEmpty &&
        locationQuests.every((q) => completedQuestIds.contains(q.id));
    final state = isCompleted
        ? _LocationState.completed
        : (isUnlocked ? _LocationState.unlocked : _LocationState.locked);
    final starsEarned = locationQuests
        .where((q) => completedQuestIds.contains(q.id))
        .fold<int>(0, (sum, q) => sum + q.starReward);

    return _MapNode(
      location: location,
      alignRight: index.isOdd,
      state: state,
      starsEarned: starsEarned,
      animation: _nodeAnimations[index],
      shakeSignal: _lockShakeSignals[index],
      isCurrent: isCurrent,
      heroProfile: heroProfile,
      onTap: () {
        if (isUnlocked) {
          _openLocation(location);
        } else {
          _showLockedHint(location, stars, index);
        }
      },
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.location,
    required this.alignRight,
    required this.state,
    required this.starsEarned,
    required this.animation,
    required this.shakeSignal,
    required this.isCurrent,
    required this.heroProfile,
    required this.onTap,
  });

  final WorldLocation location;
  final bool alignRight;
  final _LocationState state;
  final int starsEarned;
  final Animation<double> animation;
  final int shakeSignal;
  final bool isCurrent;
  final HeroProfile heroProfile;
  final VoidCallback onTap;

  String get _semanticLabel {
    switch (state) {
      case _LocationState.locked:
        return '${location.name}, locked. Earn ${location.requiredStars} '
            'stars total to unlock.';
      case _LocationState.unlocked:
        return '${location.name}, unlocked. Tap to explore.';
      case _LocationState.completed:
        return '${location.name}, completed with $starsEarned stars '
            'earned. Tap to explore again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = state == _LocationState.locked;
    final circleColor = switch (state) {
      _LocationState.locked => Colors.grey.shade300,
      _LocationState.unlocked => AppColors.leafGreen,
      _LocationState.completed => AppColors.sunshineYellow,
    };

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: _semanticLabel,
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  ShakeWidget(
                    shakeSignal: shakeSignal,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: circleColor,
                            shape: BoxShape.circle,
                            // Locked/unlocked/completed never rely on
                            // color alone (brief section 13) — each also
                            // has a distinct icon and caption below.
                            boxShadow: !isLocked
                                ? [
                                    BoxShadow(
                                      color: circleColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isLocked ? Icons.lock_rounded : location.icon,
                            color:
                                isLocked ? Colors.grey.shade600 : Colors.white,
                            size: 36,
                          ),
                        ),
                        if (state == _LocationState.completed)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.leafGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        if (isCurrent)
                          Positioned(
                            bottom: -10,
                            left: -6,
                            child: _HeroMarker(profile: heroProfile),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isLocked
                              ? Colors.grey.shade600
                              : AppColors.inkNavy,
                        ),
                  ),
                  if (state == _LocationState.locked)
                    Text(
                      '${location.requiredStars} ⭐ to unlock',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                    ),
                  if (state == _LocationState.completed)
                    Text(
                      '✓ $starsEarned ⭐ earned',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.leafGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + (0.4 * animation.value.clamp(0.0, 1.0)),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}

/// A small portrait of the child's own hero, marking their current
/// furthest-unlocked spot on the map (brief section 8) — simple
/// attach-to-a-node placement, no pathfinding or continuous animation.
class _HeroMarker extends StatelessWidget {
  const _HeroMarker({required this.profile});

  final HeroProfile profile;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your hero is here',
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.coral, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: FittedBox(
            fit: BoxFit.cover,
            child: HeroAvatarPreview(profile: profile, size: 90),
          ),
        ),
      ),
    );
  }
}
