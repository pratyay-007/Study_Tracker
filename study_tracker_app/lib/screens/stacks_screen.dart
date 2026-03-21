import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_stack.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class StacksScreen extends StatelessWidget {
  const StacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.layers, color: AppTheme.primaryBlue, size: 28),
                      const SizedBox(width: 10),
                      Text('Stacks',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      _iconButton(Icons.search, () {}),
                      const SizedBox(width: 8),
                      _iconButton(Icons.settings_outlined, () {}),
                    ],
                  ),
                ),

                // Stacks list
                Expanded(
                  child: provider.stacks.isEmpty
                      ? _buildEmptyState(context, provider)
                      : _buildStacksList(context, provider),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddStackDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
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

  Widget _buildEmptyState(BuildContext context, AppProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_outlined,
              color: AppTheme.textMuted, size: 64),
          const SizedBox(height: 16),
          Text('No stacks yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Create your first study stack',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStackDialog(context, provider),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Stack'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(160, 44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStacksList(BuildContext context, AppProvider provider) {
    return PageView.builder(
      itemCount: provider.stacks.length,
      controller: PageController(viewportFraction: 0.85),
      itemBuilder: (context, index) {
        final stack = provider.stacks[index];
        return _buildStackCard(context, provider, stack);
      },
    );
  }

  Widget _buildStackCard(
      BuildContext context, AppProvider provider, StudyStack stack) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.format_list_bulleted,
                      color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(stack.name.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${stack.topics.length}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _confirmDeleteStack(context, provider, stack),
                    child: const Icon(Icons.delete_outline,
                        color: AppTheme.textMuted, size: 18),
                  ),
                ],
              ),
            ),

            // Topics
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...stack.topics.map((topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: Key(topic.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child:
                                const Icon(Icons.delete, color: AppTheme.error),
                          ),
                          onDismissed: (_) =>
                              provider.deleteTopic(stack.id, topic.id),
                          child: GestureDetector(
                            onTap: () =>
                                provider.toggleTopic(stack.id, topic.id),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppTheme.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: topic.isCompleted
                                          ? AppTheme.primaryBlue
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: topic.isCompleted
                                            ? AppTheme.primaryBlue
                                            : AppTheme.textMuted,
                                        width: 2,
                                      ),
                                    ),
                                    child: topic.isCompleted
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 14)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          topic.title,
                                          style: TextStyle(
                                            color: topic.isCompleted
                                                ? AppTheme.textMuted
                                                : AppTheme.textPrimary,
                                            fontWeight: FontWeight.w500,
                                            decoration: topic.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (topic.subtitle.isNotEmpty)
                                          Text(topic.subtitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),

                  // Add Topic button
                  GestureDetector(
                    onTap: () =>
                        _showAddTopicDialog(context, provider, stack.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.textMuted.withValues(alpha: 0.4),
                            style: BorderStyle.solid),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add,
                              color: AppTheme.textMuted, size: 18),
                          SizedBox(width: 8),
                          Text('Add Topic',
                              style: TextStyle(color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStackDialog(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Stack'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: 'Stack name e.g. Math'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              provider.addStack(StudyStack(name: nameCtrl.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog(
      BuildContext context, AppProvider provider, String stackId) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'Topic title'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subtitleCtrl,
              decoration: const InputDecoration(hintText: 'Description (optional)'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              provider.addTopicToStack(
                  stackId,
                  StackTopic(
                    title: titleCtrl.text.trim(),
                    subtitle: subtitleCtrl.text.trim(),
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStack(
      BuildContext context, AppProvider provider, StudyStack stack) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Stack?'),
        content: Text('Are you sure you want to delete "${stack.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              provider.deleteStack(stack.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
