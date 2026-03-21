import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final avatarIcons = [
          Icons.school, Icons.code, Icons.palette,
          Icons.sports_esports, Icons.science, Icons.explore,
        ];
        final avatarColors = [
          const Color(0xFF2962FF), const Color(0xFF00C853),
          const Color(0xFFFF6D00), const Color(0xFF7C4DFF),
          const Color(0xFFE91E63), const Color(0xFF00BCD4),
        ];
        final idx = profile?.avatarIndex ?? 0;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back,
                              color: AppTheme.textPrimary),
                        ),
                        const Spacer(),
                        Text('Profile',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: avatarColors[idx].withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: avatarColors[idx], width: 3),
                    ),
                    child: Icon(avatarIcons[idx],
                        color: avatarColors[idx], size: 48),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(profile?.name ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    '${profile?.gender ?? ''} • Age ${profile?.age ?? 0}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProfileSetupScreen(isEditing: true),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Stats cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context,
                            icon: '🔥',
                            label: 'Current\nStreak',
                            value: '${provider.currentStreak} days',
                            valueColor: AppTheme.streakOrange,
                            subtitle: provider.currentStreak > 3
                                ? '↗ Top 5% this week'
                                : 'Keep going!',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            context,
                            icon: '🏆',
                            label: 'Total XP',
                            value: '${provider.totalXP}',
                            valueColor: AppTheme.xpPurple,
                            subtitle:
                                'Level ${provider.level} ${_levelName(provider.level)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Study Activity (GitHub-style grid)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Study Activity',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text('Past 6 months',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildActivityGrid(provider),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Less ',
                                style: Theme.of(context).textTheme.bodySmall),
                            ...[
                              AppTheme.gridEmpty,
                              AppTheme.gridLight,
                              AppTheme.gridMedium,
                              AppTheme.gridDark,
                              AppTheme.gridFull,
                            ].map((c) => Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                    color: c,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )),
                            Text(' More',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Achievements
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Achievements',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _achievementCard(
                              context,
                              icon: Icons.book,
                              title: 'Night Owl',
                              subtitle: 'Study after 10PM',
                              unlocked: provider.totalXP > 100,
                            ),
                            const SizedBox(width: 12),
                            _achievementCard(
                              context,
                              icon: Icons.lock_outline,
                              title: 'Early Bird',
                              subtitle: 'Locked',
                              unlocked: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _levelName(int level) {
    if (level <= 5) return 'Beginner';
    if (level <= 15) return 'Intermediate';
    if (level <= 25) return 'Advanced';
    return 'Expert';
  }

  Widget _statCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color valueColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: valueColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActivityGrid(AppProvider provider) {
    final now = DateTime.now();
    final completedDays = provider.completedDays;
    final weeks = 26; // ~6 months
    final fmt = DateFormat('yyyy-MM-dd');

    // Build grid data: 7 rows x 26 columns
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(weeks, (weekIdx) {
            return Column(
              children: List.generate(7, (dayIdx) {
                final daysFromNow = (weeks - 1 - weekIdx) * 7 + (6 - dayIdx);
                final day = now.subtract(Duration(days: daysFromNow));
                final key = fmt.format(day);
                final isCompleted = completedDays.contains(key);
                final isFuture = day.isAfter(now);

                Color color;
                if (isFuture) {
                  color = Colors.transparent;
                } else if (isCompleted) {
                  // Vary intensity (simple approach)
                  final tasks = provider.tasksForDate(key);
                  final completedCount =
                      tasks.where((t) => t.isCompleted).length;
                  if (completedCount >= 5) {
                    color = AppTheme.gridFull;
                  } else if (completedCount >= 3) {
                    color = AppTheme.gridDark;
                  } else if (completedCount >= 2) {
                    color = AppTheme.gridMedium;
                  } else {
                    color = AppTheme.gridLight;
                  }
                } else {
                  color = AppTheme.gridEmpty;
                }

                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _achievementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: unlocked
                    ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: unlocked ? AppTheme.primaryBlue : AppTheme.textMuted,
                  size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: unlocked
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
