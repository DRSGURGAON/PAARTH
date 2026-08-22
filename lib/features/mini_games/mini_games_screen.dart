import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'math_dash_screen.dart';
import 'memory_master_screen.dart';
import 'pattern_power_screen.dart';

/// Hub listing the playable mini-games. Only games that actually exist
/// appear here — Word Builder and Find & Discover cards get added when
/// Phase 6 lands, never before.
class MiniGamesScreen extends StatelessWidget {
  const MiniGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini-Games')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _MiniGameCard(
              title: 'Math Dash',
              subtitle: 'Quick number puzzles!',
              icon: Icons.calculate_rounded,
              color: AppColors.skyBlue,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MathDashScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _MiniGameCard(
              title: 'Memory Master',
              subtitle: 'Watch closely, then remember!',
              icon: Icons.psychology_rounded,
              color: AppColors.coral,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MemoryMasterScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _MiniGameCard(
              title: 'Pattern Power',
              subtitle: 'What comes next?',
              icon: Icons.pattern_rounded,
              color: AppColors.grapePurple,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PatternPowerScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniGameCard extends StatelessWidget {
  const _MiniGameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
