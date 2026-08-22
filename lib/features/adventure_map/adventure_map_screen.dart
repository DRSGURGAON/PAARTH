import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/world_location.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/worlds/jungle_world.dart';
import '../quests/location_quests_screen.dart';

/// The Jungle Adventure world map: a small winding trail of location
/// nodes rather than a static list, each animating in on entry. Locked
/// nodes show what's needed to open them; unlocked nodes lead to that
/// location's quest list.
class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _nodeAnimations;

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
    // Stars may have been earned inside — refresh lock states on return.
    if (mounted) setState(() {});
  }

  void _showLockedHint(WorldLocation location, int stars) {
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
    final stars = ProgressRepository(AppScope.of(context).storage).stars;

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
                  _MapNode(
                    location: JungleWorld.locations[i],
                    alignRight: i.isOdd,
                    isUnlocked:
                        JungleWorld.locations[i].isUnlockedFor(stars),
                    animation: _nodeAnimations[i],
                    onTap: () {
                      final location = JungleWorld.locations[i];
                      if (location.isUnlockedFor(stars)) {
                        _openLocation(location);
                      } else {
                        _showLockedHint(location, stars);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.location,
    required this.alignRight,
    required this.isUnlocked,
    required this.animation,
    required this.onTap,
  });

  final WorldLocation location;
  final bool alignRight;
  final bool isUnlocked;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.leafGreen
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: AppColors.leafGreen.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isUnlocked ? location.icon : Icons.lock_rounded,
                    color: isUnlocked ? Colors.white : Colors.grey.shade600,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  location.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUnlocked
                            ? AppColors.inkNavy
                            : Colors.grey.shade600,
                      ),
                ),
                if (!isUnlocked)
                  Text(
                    '${location.requiredStars} ⭐ to unlock',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                  ),
              ],
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
