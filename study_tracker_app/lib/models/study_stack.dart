import 'package:uuid/uuid.dart';

class StackTopic {
  final String id;
  String title;
  String subtitle;
  bool isCompleted;

  StackTopic({
    String? id,
    required this.title,
    this.subtitle = '',
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'isCompleted': isCompleted,
      };

  factory StackTopic.fromJson(Map<String, dynamic> json) => StackTopic(
        id: json['id'],
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
      );
}

class StudyStack {
  final String id;
  String name;
  String icon;
  List<StackTopic> topics;

  StudyStack({
    String? id,
    required this.name,
    this.icon = '📚',
    List<StackTopic>? topics,
  })  : id = id ?? const Uuid().v4(),
        topics = topics ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'topics': topics.map((t) => t.toJson()).toList(),
      };

  factory StudyStack.fromJson(Map<String, dynamic> json) => StudyStack(
        id: json['id'],
        name: json['name'] ?? '',
        icon: json['icon'] ?? '📚',
        topics: (json['topics'] as List<dynamic>?)
                ?.map((t) => StackTopic.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
