import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/task_model.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/add_task_dialog.dart';
import 'widgets/bottom_dock.dart';
import 'widgets/date_selector.dart';
import 'widgets/productivity_card.dart';
import 'widgets/task_card.dart';
import 'widgets/task_detail_sheet.dart';
import 'widgets/timeline_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await StorageService.init();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task & Study Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0; // 0: Dashboard, 1: Timeline
  DateTime _selectedDate = DateTime.now();
  List<TaskModel> _tasks = [];
  TaskCategory? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = StorageService.getTasksForDate(_selectedDate);
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadTasks();
  }

  void _openAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskDialog(
        initialDate: _selectedDate,
        onTaskAdded: _loadTasks,
      ),
    );
  }

  void _openTaskDetail(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        task: task,
        onTaskUpdated: _loadTasks,
        onDelete: () async {
          await StorageService.deleteTask(task.id);
          _loadTasks();
        },
      ),
    );
  }

  void _toggleTaskComplete(TaskModel task) async {
    await StorageService.toggleTaskCompleted(task.id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedCategoryFilter == null
        ? _tasks
        : _tasks.where((t) => t.category == _selectedCategoryFilter).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Content Area
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _currentTab == 0
                    ? _buildDashboardView(filteredTasks)
                    : _buildTimelineScheduleView(filteredTasks),
              ),
            ),

            // Floating Navigation Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: BottomDock(
                  currentIndex: _currentTab,
                  onTabSelected: (index) {
                    setState(() {
                      _currentTab = index;
                    });
                  },
                  onAddTask: _openAddTaskModal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 0: Dashboard with Productivity Matrix & Task Cards (Screen 1 style)
  Widget _buildDashboardView(List<TaskModel> displayTasks) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      children: [
        // Productivity Header
        ProductivityCard(
          tasks: _tasks,
          onProfileTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Offline Local Storage: Hive DB active')),
            );
          },
        ),
        const SizedBox(height: 16),

        // Quick Category Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryFilterChip(null, 'ALL'),
              const SizedBox(width: 8),
              _buildCategoryFilterChip(TaskCategory.coding, 'CODING'),
              const SizedBox(width: 8),
              _buildCategoryFilterChip(TaskCategory.study, 'STUDY'),
              const SizedBox(width: 8),
              _buildCategoryFilterChip(TaskCategory.project, 'PROJECT'),
              const SizedBox(width: 8),
              _buildCategoryFilterChip(TaskCategory.review, 'REVIEW'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tasks List
        if (displayTasks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.playlist_add_check_rounded, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                const Text(
                  'No tasks scheduled for today!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap the + button below to add your first study or coding task.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _openAddTaskModal,
                  icon: const Icon(Icons.add, color: AppColors.darkCard),
                  label: const Text('Add Task', style: TextStyle(color: AppColors.darkCard, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.limeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          )
        else
          ...displayTasks.map((task) {
            return TaskCard(
              task: task,
              onTap: () => _openTaskDetail(task),
              onToggleComplete: () => _toggleTaskComplete(task),
            );
          }),
      ],
    );
  }

  Widget _buildCategoryFilterChip(TaskCategory? category, String label) {
    final isSelected = _selectedCategoryFilter == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryFilter = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.darkCard : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isSelected ? AppColors.limeAccent : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // TAB 1: Hourly Timeline Schedule View (Screen 2 style)
  Widget _buildTimelineScheduleView(List<TaskModel> displayTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Horizontal Date Selector
        DateSelector(
          selectedDate: _selectedDate,
          onDateSelected: _onDateChanged,
        ),
        const SizedBox(height: 16),

        // Hourly Timeline
        Expanded(
          child: TimelineView(
            tasks: displayTasks,
            onTaskTap: _openTaskDetail,
            onToggleComplete: _toggleTaskComplete,
          ),
        ),
      ],
    );
  }
}
