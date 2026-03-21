import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final tasks = provider.todayTasks;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  _buildTopBar(context, provider),
                  const SizedBox(height: 24),

                  // Daily Stats
                  Text('DAILY STATS',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  _buildStatsRow(context, provider),
                  const SizedBox(height: 24),

                  // Today's Tasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TODAY'S TASKS",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(letterSpacing: 1.5)),
                      Text('VIEW ALL',
                          style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...tasks.map((task) => _buildTaskCard(context, provider, task)),
                  const SizedBox(height: 12),
                  _buildAddTaskButton(context, provider),
                  const SizedBox(height: 20),

                  // Streak banner
                  _buildStreakBanner(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, AppProvider provider) {
    final avatarIcons = [
      Icons.school, Icons.code, Icons.palette,
      Icons.sports_esports, Icons.science, Icons.explore,
    ];
    final avatarColors = [
      const Color(0xFF2962FF), const Color(0xFF00C853),
      const Color(0xFFFF6D00), const Color(0xFF7C4DFF),
      const Color(0xFFE91E63), const Color(0xFF00BCD4),
    ];
    final idx = provider.profile?.avatarIndex ?? 0;

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColors[idx].withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: avatarColors[idx], width: 2),
            ),
            child: Icon(avatarIcons[idx], color: avatarColors[idx], size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WELCOME BACK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2, color: AppTheme.textMuted)),
              Text(
                '${provider.greeting}, ${provider.profile?.name ?? 'User'}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        _iconButton(Icons.settings_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }),
        const SizedBox(width: 8),
        _iconButton(Icons.notifications_outlined, () {}),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _hydrationCard(context, provider),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            icon: Icons.nightlight_round,
            iconColor: AppTheme.accentBlue,
            label: 'Sleep',
            value: '${provider.sleep.toStringAsFixed(0)}h',
            unit: 'rested',
            progress: (provider.sleep / 10).clamp(0.0, 1.0),
            onTap: () => _showSleepDialog(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _hydrationCard(BuildContext context, AppProvider provider) {
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
              Icon(Icons.water_drop, color: AppTheme.primaryBlue, size: 18),
              const SizedBox(width: 6),
              Text('Hydration', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${provider.hydration}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 28)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('glasses',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _roundButton(Icons.remove, () => provider.decrementHydration()),
              const SizedBox(width: 12),
              _roundButton(Icons.add, () => provider.incrementHydration()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required double progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 6),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 28)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child:
                      Text(unit, style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.cardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepDialog(BuildContext context, AppProvider provider) {
    final controller =
        TextEditingController(text: provider.sleep.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hours slept last night'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 7'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final h = double.tryParse(controller.text) ?? 0;
              provider.setSleep(h);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
      BuildContext context, AppProvider provider, StudyTask task) {
    final tagColors = {
      'STUDY': AppTheme.primaryBlue,
      'CODING': AppTheme.success,
      'REVIEW': AppTheme.warning,
      'PROJECT': AppTheme.streakOrange,
      'EXAM PREP': AppTheme.xpPurple,
    };
    final tagColor = tagColors[task.tag] ?? AppTheme.accentBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete, color: AppTheme.error),
        ),
        onDismissed: (_) => provider.deleteTask(task.id),
        child: GestureDetector(
          onLongPress: () => _showEditTaskDialog(context, provider, task),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => provider.toggleTask(task.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppTheme.primaryBlue
                            : AppTheme.textMuted,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          '${task.category}${task.duration.isNotEmpty ? " • ${task.duration}" : ""}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(task.tag,
                      style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, AppProvider provider) {
    return GestureDetector(
      onTap: () => _showAddTaskDialog(context, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline,
                color: AppTheme.textMuted, size: 20),
            SizedBox(width: 8),
            Text('ADD NEW TASK',
                style: TextStyle(
                    color: AppTheme.textMuted,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBanner(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Streak',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('${provider.currentStreak} days',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppTheme.streakOrange)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Total XP', style: Theme.of(context).textTheme.bodySmall),
              Text('${provider.totalXP}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppTheme.xpPurple)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, AppProvider provider,
      {String? forDate}) {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    String selectedTag = 'STUDY';
    String selectedPriority = 'MED';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: 'Task title'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Category (e.g. Calculus)'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Duration (e.g. 45 mins)'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: ['STUDY', 'CODING', 'REVIEW', 'PROJECT']
                      .map((t) => ChoiceChip(
                            label: Text(t, style: const TextStyle(fontSize: 11)),
                            selected: selectedTag == t,
                            onSelected: (s) =>
                                setDialogState(() => selectedTag = t),
                            selectedColor: AppTheme.primaryBlue,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                provider.addTask(StudyTask(
                  title: titleCtrl.text.trim(),
                  subtitle: categoryCtrl.text.trim(),
                  category: categoryCtrl.text.trim(),
                  duration: durationCtrl.text.trim(),
                  tag: selectedTag,
                  priority: selectedPriority,
                  date: forDate ?? provider.todayKey,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(
      BuildContext context, AppProvider provider, StudyTask task) {
    final titleCtrl = TextEditingController(text: task.title);
    final categoryCtrl = TextEditingController(text: task.category);
    final durationCtrl = TextEditingController(text: task.duration);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(hintText: 'Task title'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(hintText: 'Category'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(hintText: 'Duration'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
          ElevatedButton(
            onPressed: () {
              task.title = titleCtrl.text.trim();
              task.category = categoryCtrl.text.trim();
              task.duration = durationCtrl.text.trim();
              provider.updateTask(task);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
