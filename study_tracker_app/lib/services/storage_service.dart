import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/study_task.dart';
import '../models/study_stack.dart';
import '../models/diary_entry.dart';

class StorageService {
  static const String _profileKey = 'user_profile';
  static const String _firstLaunchKey = 'first_launch';
  static const String _tasksKey = 'tasks';
  static const String _stacksKey = 'stacks';
  static const String _diaryKey = 'diary';
  static const String _hydrationKey = 'hydration';
  static const String _sleepKey = 'sleep';
  static const String _xpKey = 'total_xp';
  static const String _completedDaysKey = 'completed_days';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // First Launch
  bool get isFirstLaunch => _prefs.getBool(_firstLaunchKey) ?? true;
  Future<void> setFirstLaunchDone() async =>
      await _prefs.setBool(_firstLaunchKey, false);

  // Profile
  UserProfile? getProfile() {
    final data = _prefs.getString(_profileKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // Tasks
  List<StudyTask> getTasks() {
    final data = _prefs.getString(_tasksKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => StudyTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<StudyTask> tasks) async {
    await _prefs.setString(
        _tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  // Stacks
  List<StudyStack> getStacks() {
    final data = _prefs.getString(_stacksKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => StudyStack.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveStacks(List<StudyStack> stacks) async {
    await _prefs.setString(
        _stacksKey, jsonEncode(stacks.map((s) => s.toJson()).toList()));
  }

  // Diary
  Map<String, DiaryEntry> getDiaryEntries() {
    final data = _prefs.getString(_diaryKey);
    if (data == null) return {};
    final map = jsonDecode(data) as Map<String, dynamic>;
    return map.map((key, value) =>
        MapEntry(key, DiaryEntry.fromJson(value as Map<String, dynamic>)));
  }

  Future<void> saveDiaryEntries(Map<String, DiaryEntry> entries) async {
    await _prefs.setString(_diaryKey,
        jsonEncode(entries.map((k, v) => MapEntry(k, v.toJson()))));
  }

  // Hydration
  int getHydration() => _prefs.getInt(_hydrationKey) ?? 0;
  Future<void> saveHydration(int glasses) async =>
      await _prefs.setInt(_hydrationKey, glasses);

  // Sleep
  double getSleep() => _prefs.getDouble(_sleepKey) ?? 0.0;
  Future<void> saveSleep(double hours) async =>
      await _prefs.setDouble(_sleepKey, hours);

  // XP
  int getXP() => _prefs.getInt(_xpKey) ?? 0;
  Future<void> saveXP(int xp) async => await _prefs.setInt(_xpKey, xp);

  // Completed Days (for streak & activity grid)
  Set<String> getCompletedDays() {
    final data = _prefs.getStringList(_completedDaysKey);
    return data?.toSet() ?? {};
  }

  Future<void> saveCompletedDays(Set<String> days) async {
    await _prefs.setStringList(_completedDaysKey, days.toList());
  }
}
