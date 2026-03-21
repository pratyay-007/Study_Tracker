import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DateTime _selectedDate;
  late TextEditingController _reflectionsCtrl;
  late TextEditingController _studiedCtrl;
  late TextEditingController _thoughtsCtrl;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _reflectionsCtrl = TextEditingController();
    _studiedCtrl = TextEditingController();
    _thoughtsCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntry();
    });
  }

  @override
  void dispose() {
    _reflectionsCtrl.dispose();
    _studiedCtrl.dispose();
    _thoughtsCtrl.dispose();
    super.dispose();
  }

  void _loadEntry() {
    final provider = context.read<AppProvider>();
    final key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final entry = provider.getDiaryForDate(key);
    _reflectionsCtrl.text = entry.reflections;
    _studiedCtrl.text = entry.studiedToday;
    _thoughtsCtrl.text = entry.thoughts;
    _hasChanges = false;
    setState(() {});
  }

  void _saveEntry() {
    final provider = context.read<AppProvider>();
    final key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    provider.saveDiaryEntry(DiaryEntry(
      date: key,
      reflections: _reflectionsCtrl.text,
      studiedToday: _studiedCtrl.text,
      thoughts: _thoughtsCtrl.text,
    ));
    _hasChanges = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry saved!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    setState(() {});
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _selectedDate = picked;
      _loadEntry();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel =
        DateFormat('EEEE, MMM d').format(_selectedDate).toUpperCase();
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Text('Daily Diary',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: const Icon(Icons.calendar_today,
                          color: AppTheme.textSecondary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: const Icon(Icons.settings_outlined,
                        color: AppTheme.textSecondary, size: 18),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date label
                    Text(dayLabel,
                        style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(
                      isToday
                          ? 'Reflect on your growth'
                          : 'Diary for ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 28),

                    // Daily Reflections
                    Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('Daily Reflections',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _diaryField(
                      controller: _reflectionsCtrl,
                      hint:
                          'How was your day? Write your reflections here...',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),

                    // What I studied today
                    Row(
                      children: [
                        const Text('📖', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('What I studied today',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _diaryField(
                      controller: _studiedCtrl,
                      hint:
                          'List the topics and concepts you covered...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Thoughts
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('Thoughts',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _diaryField(
                      controller: _thoughtsCtrl,
                      hint: 'Any stray ideas or future goals?',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _saveEntry,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 8),
                    Text('Save Entry'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diaryField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 4,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) {
          if (!_hasChanges) setState(() => _hasChanges = true);
        },
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
