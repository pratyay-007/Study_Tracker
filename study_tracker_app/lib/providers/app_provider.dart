import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/study_task.dart';
import '../models/study_stack.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage;

  UserProfile? _profile;
  List<StudyTask> _tasks = [];
  List<StudyStack> _stacks = [];
  Map<String, DiaryEntry> _diaryEntries = {};
  int _hydration = 0;
  double _sleep = 0.0;
  int _totalXP = 0;
  Set<String> _completedDays = {};

  AppProvider(this._storage) {
    _loadAll();
  }

  // Getters
  UserProfile? get profile => _profile;
  List<StudyTask> get allTasks => _tasks;
  List<StudyStack> get stacks => _stacks;
  Map<String, DiaryEntry> get diaryEntries => _diaryEntries;
  int get hydration => _hydration;
  double get sleep => _sleep;
  int get totalXP => _totalXP;
  Set<String> get completedDays => _completedDays;
  bool get isFirstLaunch => _storage.isFirstLaunch;

  String get todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<StudyTask> get todayTasks =>
      _tasks.where((t) => t.date == todayKey).toList();

  List<StudyTask> tasksForDate(String date) =>
      _tasks.where((t) => t.date == date).toList();

  int get currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    // Check today first
    if (_completedDays.contains(fmt.format(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    while (_completedDays.contains(fmt.format(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get level => (_totalXP / 500).floor() + 1;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _loadAll() {
    _profile = _storage.getProfile();
    _tasks = _storage.getTasks();
    _stacks = _storage.getStacks();
    _diaryEntries = _storage.getDiaryEntries();
    _hydration = _storage.getHydration();
    _sleep = _storage.getSleep();
    _totalXP = _storage.getXP();
    _completedDays = _storage.getCompletedDays();
    notifyListeners();
  }

  // Profile
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _storage.saveProfile(profile);
    await _storage.setFirstLaunchDone();
    notifyListeners();
  }

  // Tasks
  Future<void> addTask(StudyTask task) async {
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.isCompleted = !task.isCompleted;

    if (task.isCompleted) {
      _totalXP += 10;
      _completedDays.add(task.date);

      // Check if all tasks for that day are completed
      final dayTasks = tasksForDate(task.date);
      if (dayTasks.every((t) => t.isCompleted)) {
        _totalXP += 50; // Bonus for completing all tasks
      }

      await _storage.saveXP(_totalXP);
      await _storage.saveCompletedDays(_completedDays);
    } else {
      _totalXP = (_totalXP - 10).clamp(0, 999999);
      await _storage.saveXP(_totalXP);
    }

    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(StudyTask updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _tasks[idx] = updated;
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  // Stacks
  Future<void> addStack(StudyStack stack) async {
    _stacks.add(stack);
    await _storage.saveStacks(_stacks);
    notifyListeners();
  }

  Future<void> updateStack(StudyStack updated) async {
    final idx = _stacks.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _stacks[idx] = updated;
      await _storage.saveStacks(_stacks);
      notifyListeners();
    }
  }

  Future<void> deleteStack(String stackId) async {
    _stacks.removeWhere((s) => s.id == stackId);
    await _storage.saveStacks(_stacks);
    notifyListeners();
  }

  Future<void> addTopicToStack(String stackId, StackTopic topic) async {
    final stack = _stacks.firstWhere((s) => s.id == stackId);
    stack.topics.add(topic);
    await _storage.saveStacks(_stacks);
    notifyListeners();
  }

  Future<void> toggleTopic(String stackId, String topicId) async {
    final stack = _stacks.firstWhere((s) => s.id == stackId);
    final topic = stack.topics.firstWhere((t) => t.id == topicId);
    topic.isCompleted = !topic.isCompleted;
    await _storage.saveStacks(_stacks);
    notifyListeners();
  }

  Future<void> deleteTopic(String stackId, String topicId) async {
    final stack = _stacks.firstWhere((s) => s.id == stackId);
    stack.topics.removeWhere((t) => t.id == topicId);
    await _storage.saveStacks(_stacks);
    notifyListeners();
  }

  // Diary
  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    _diaryEntries[entry.date] = entry;
    await _storage.saveDiaryEntries(_diaryEntries);
    notifyListeners();
  }

  DiaryEntry getDiaryForDate(String date) {
    return _diaryEntries[date] ?? DiaryEntry(date: date);
  }

  // Hydration
  Future<void> incrementHydration() async {
    _hydration++;
    await _storage.saveHydration(_hydration);
    notifyListeners();
  }

  Future<void> decrementHydration() async {
    if (_hydration > 0) {
      _hydration--;
      await _storage.saveHydration(_hydration);
      notifyListeners();
    }
  }

  Future<void> resetHydration() async {
    _hydration = 0;
    await _storage.saveHydration(_hydration);
    notifyListeners();
  }

  // Sleep
  Future<void> setSleep(double hours) async {
    _sleep = hours;
    await _storage.saveSleep(_sleep);
    notifyListeners();
  }
}
