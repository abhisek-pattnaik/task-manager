import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class StorageService {
  static const String _boxName = 'tasks_box';
  static Box? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    
    // Seed default study/coding tasks if first time
    if (_box!.isEmpty) {
      await _seedDefaultTasks();
    }
  }

  static Future<void> _seedDefaultTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const uuid = Uuid();

    final defaultTasks = [
      TaskModel(
        id: uuid.v4(),
        title: 'Morning Algorithm & Data Structures',
        description: 'Practice LeetCode / NeetCode problems on Dynamic Programming and Graphs.',
        date: today,
        startTime: '08:30 AM',
        endTime: '10:00 AM',
        priority: TaskPriority.high,
        category: TaskCategory.study,
        colorStyle: 'mint',
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Solve 2 Graph BFS/DFS questions', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Review memoization DP pattern', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Document optimal solution notes', isCompleted: false),
        ],
      ),
      TaskModel(
        id: uuid.v4(),
        title: 'Backend API & Database Design',
        description: 'Implement JWT authentication, role-based access control, and migration scripts.',
        date: today,
        startTime: '10:30 AM',
        endTime: '12:30 PM',
        priority: TaskPriority.high,
        category: TaskCategory.coding,
        colorStyle: 'lavender',
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Design user & permissions schema', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Implement refreshToken rotation', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Write integration test cases', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Benchmark query performance', isCompleted: false),
        ],
      ),
      TaskModel(
        id: uuid.v4(),
        title: 'Frontend UI & State Management',
        description: 'Complete dashboard timeline layout, interactive dock, and step checklist.',
        date: today,
        startTime: '02:00 PM',
        endTime: '04:30 PM',
        priority: TaskPriority.normal,
        category: TaskCategory.coding,
        colorStyle: 'dark',
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Wireframe time-slot widget', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Connect Hive local database', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Smooth slide-up task details', isCompleted: false),
        ],
      ),
      TaskModel(
        id: uuid.v4(),
        title: 'System Design Architecture Reading',
        description: 'Read Chapter 4 on Distributed Caching & Message Queues.',
        date: today,
        startTime: '05:30 PM',
        endTime: '07:00 PM',
        priority: TaskPriority.normal,
        category: TaskCategory.study,
        colorStyle: 'yellow',
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Read Redis vs Memcached architecture', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Summarize Kafka partitioning strategy', isCompleted: false),
        ],
      ),
    ];

    for (var task in defaultTasks) {
      await _box!.put(task.id, task.toMap());
    }
  }

  static List<TaskModel> getAllTasks() {
    if (_box == null) return [];
    final List<TaskModel> tasks = [];
    for (var key in _box!.keys) {
      final data = _box!.get(key);
      if (data is Map) {
        tasks.add(TaskModel.fromMap(data));
      }
    }
    // Sort by startTime / date
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    return tasks;
  }

  static List<TaskModel> getTasksForDate(DateTime date) {
    final all = getAllTasks();
    return all.where((t) =>
        t.date.year == date.year &&
        t.date.month == date.month &&
        t.date.day == date.day).toList();
  }

  static Future<void> saveTask(TaskModel task) async {
    if (_box == null) return;
    await _box!.put(task.id, task.toMap());
  }

  static Future<void> deleteTask(String id) async {
    if (_box == null) return;
    await _box!.delete(id);
  }

  static Future<void> toggleSubtask(String taskId, String subtaskId) async {
    if (_box == null) return;
    final data = _box!.get(taskId);
    if (data is Map) {
      final task = TaskModel.fromMap(data);
      for (var s in task.subtasks) {
        if (s.id == subtaskId) {
          s.isCompleted = !s.isCompleted;
          break;
        }
      }
      // Auto complete main task if all subtasks completed
      if (task.subtasks.isNotEmpty) {
        task.isCompleted = task.subtasks.every((s) => s.isCompleted);
      }
      await _box!.put(taskId, task.toMap());
    }
  }

  static Future<void> toggleTaskCompleted(String taskId) async {
    if (_box == null) return;
    final data = _box!.get(taskId);
    if (data is Map) {
      final task = TaskModel.fromMap(data);
      task.isCompleted = !task.isCompleted;
      for (var s in task.subtasks) {
        s.isCompleted = task.isCompleted;
      }
      await _box!.put(taskId, task.toMap());
    }
  }
}
