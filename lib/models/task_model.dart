import 'package:uuid/uuid.dart';

class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<dynamic, dynamic> map) {
    return SubTask(
      id: map['id']?.toString() ?? const Uuid().v4(),
      title: map['title']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
    );
  }
}

enum TaskPriority { low, normal, high }

enum TaskCategory { study, coding, project, personal, review }

class TaskModel {
  final String id;
  String title;
  String description;
  DateTime date;
  String startTime; // e.g. "09:00 AM"
  String endTime;   // e.g. "10:30 AM"
  TaskPriority priority;
  TaskCategory category;
  List<SubTask> subtasks;
  bool isCompleted;
  String colorStyle; // 'yellow', 'lavender', 'dark', 'mint'

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.priority = TaskPriority.normal,
    this.category = TaskCategory.coding,
    List<SubTask>? subtasks,
    this.isCompleted = false,
    this.colorStyle = 'yellow',
  }) : subtasks = subtasks ?? [];

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isCompleted).length;

  double get progress =>
      subtasks.isEmpty ? (isCompleted ? 1.0 : 0.0) : completedSubtasksCount / subtasks.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'priority': priority.name,
      'category': category.name,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'isCompleted': isCompleted,
      'colorStyle': colorStyle,
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(map['date'].toString());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final subtasksList = (map['subtasks'] as List<dynamic>?)
            ?.map((e) => SubTask.fromMap(e as Map<dynamic, dynamic>))
            .toList() ??
        [];

    TaskPriority prio = TaskPriority.normal;
    for (var p in TaskPriority.values) {
      if (p.name == map['priority']) {
        prio = p;
        break;
      }
    }

    TaskCategory cat = TaskCategory.coding;
    for (var c in TaskCategory.values) {
      if (c.name == map['category']) {
        cat = c;
        break;
      }
    }

    return TaskModel(
      id: map['id']?.toString() ?? const Uuid().v4(),
      title: map['title']?.toString() ?? 'Untitled Task',
      description: map['description']?.toString() ?? '',
      date: parsedDate,
      startTime: map['startTime']?.toString() ?? '09:00 AM',
      endTime: map['endTime']?.toString() ?? '10:00 AM',
      priority: prio,
      category: cat,
      subtasks: subtasksList,
      isCompleted: map['isCompleted'] == true,
      colorStyle: map['colorStyle']?.toString() ?? 'yellow',
    );
  }
}
