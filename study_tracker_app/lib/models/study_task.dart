import 'package:uuid/uuid.dart';

class StudyTask {
  final String id;
  String title;
  String subtitle;
  String category;
  String duration;
  String priority; // HIGH, MED, LOW
  String tag; // STUDY, CODING, REVIEW, PROJECT, etc.
  bool isCompleted;
  String date; // yyyy-MM-dd

  StudyTask({
    String? id,
    required this.title,
    this.subtitle = '',
    this.category = '',
    this.duration = '',
    this.priority = 'MED',
    this.tag = 'STUDY',
    this.isCompleted = false,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'duration': duration,
        'priority': priority,
        'tag': tag,
        'isCompleted': isCompleted,
        'date': date,
      };

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
        id: json['id'],
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        category: json['category'] ?? '',
        duration: json['duration'] ?? '',
        priority: json['priority'] ?? 'MED',
        tag: json['tag'] ?? 'STUDY',
        isCompleted: json['isCompleted'] ?? false,
        date: json['date'] ?? '',
      );
}
