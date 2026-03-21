import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/study_task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String _dayKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final selectedKey = _dayKey(_selectedDay);
        final tasks = provider.tasksForDate(selectedKey);
        final completedDays = provider.completedDays;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.terminal,
                          color: AppTheme.primaryBlue, size: 24),
                      const SizedBox(width: 10),
                      Text('Study.log',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      _iconButton(Icons.search, () {}),
                      const SizedBox(width: 8),
                      _avatarButton(context, provider),
                    ],
                  ),
                ),

                // Calendar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2024, 1, 1),
                    lastDay: DateTime(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (ctx, day, focusedDay) {
                        final key = _dayKey(day);
                        final hasCompleted = completedDays.contains(key);
                        return _buildDayCell(day, hasCompleted, false, false);
                      },
                      todayBuilder: (ctx, day, focusedDay) {
                        final key = _dayKey(day);
                        final hasCompleted = completedDays.contains(key);
                        return _buildDayCell(day, hasCompleted, true, false);
                      },
                      selectedBuilder: (ctx, day, focusedDay) {
                        return _buildDayCell(day, false, false, true);
                      },
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: false,
                      formatButtonVisible: false,
                      titleTextStyle: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold) ??
                          const TextStyle(),
                      leftChevronIcon: const Icon(Icons.chevron_left,
                          color: AppTheme.textSecondary),
                      rightChevronIcon: const Icon(Icons.chevron_right,
                          color: AppTheme.textSecondary),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      weekendStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(color: AppTheme.textPrimary),
                      weekendTextStyle:
                          TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tasks header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('Tasks',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Text(DateFormat('MMM d').format(_selectedDay),
                          style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showAddTaskForDate(
                            context, provider, selectedKey),
                        child: Text('+ New Task',
                            style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Task list
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text('No tasks for this day',
                              style: Theme.of(context).textTheme.bodySmall),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tasks.length,
                          itemBuilder: (ctx, i) =>
                              _buildTaskTile(context, provider, tasks[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCell(
      DateTime day, bool hasCompleted, bool isToday, bool isSelected) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue
            : isToday
                ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                : AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected || isToday
                  ? Colors.white
                  : AppTheme.textPrimary,
              fontWeight:
                  isToday || isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isToday && !isSelected)
            Text('TODAY',
                style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 8,
                    fontWeight: FontWeight.bold)),
          if (hasCompleted && !isSelected)
            Icon(Icons.check_circle, color: AppTheme.success, size: 12),
        ],
      ),
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

  Widget _avatarButton(BuildContext context, AppProvider provider) {
    final name = provider.profile?.name ?? 'U';
    final initials =
        name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.primaryBlue,
      child: Text(initials.toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTaskTile(
      BuildContext context, AppProvider provider, StudyTask task) {
    final priorityColors = {
      'HIGH': AppTheme.streakOrange,
      'MED': AppTheme.accentBlue,
      'LOW': AppTheme.success,
    };
    final statusLabel = task.isCompleted ? 'DONE' : task.priority;
    final statusColor = task.isCompleted
        ? AppTheme.success
        : (priorityColors[task.priority] ?? AppTheme.accentBlue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                width: 26,
                height: 26,
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
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
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
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.category.isNotEmpty || task.duration.isNotEmpty)
                    Text(
                      '${task.duration}${task.category.isNotEmpty ? " • ${task.tag}" : ""}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(statusLabel,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskForDate(
      BuildContext context, AppProvider provider, String date) {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    String tag = 'STUDY';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Add Task for ${DateFormat('MMM d').format(_selectedDay)}'),
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
                  controller: durationCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Duration e.g. 1.5H'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: ['STUDY', 'CODING', 'REVIEW', 'PROJECT', 'EXAM PREP']
                      .map((t) => ChoiceChip(
                            label: Text(t, style: const TextStyle(fontSize: 10)),
                            selected: tag == t,
                            onSelected: (_) =>
                                setDialogState(() => tag = t),
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
                  duration: durationCtrl.text.trim(),
                  tag: tag,
                  date: date,
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
}
