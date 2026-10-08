import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class TaskDetailSheet extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTaskUpdated;
  final VoidCallback onDelete;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onDelete,
  });

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final TextEditingController _newStepController = TextEditingController();
  bool _isAddingStep = false;

  @override
  void dispose() {
    _newStepController.dispose();
    super.dispose();
  }

  void _handleAddStep() async {
    final title = _newStepController.text.trim();
    if (title.isEmpty) return;

    final newSubtask = SubTask(
      id: const Uuid().v4(),
      title: title,
      isCompleted: false,
    );

    widget.task.subtasks.add(newSubtask);
    widget.task.isCompleted = false;
    await StorageService.saveTask(widget.task);
    _newStepController.clear();
    setState(() {
      _isAddingStep = false;
    });
    widget.onTaskUpdated();
  }

  void _handleToggleSubtask(SubTask subtask) async {
    await StorageService.toggleSubtask(widget.task.id, subtask.id);
    setState(() {
      subtask.isCompleted = !subtask.isCompleted;
      if (widget.task.subtasks.isNotEmpty) {
        widget.task.isCompleted = widget.task.subtasks.every((s) => s.isCompleted);
      }
    });
    widget.onTaskUpdated();
  }

  void _handleDeleteSubtask(SubTask subtask) async {
    widget.task.subtasks.removeWhere((s) => s.id == subtask.id);
    await StorageService.saveTask(widget.task);
    setState(() {});
    widget.onTaskUpdated();
  }

  void _handleToggleMainTask() async {
    await StorageService.toggleTaskCompleted(widget.task.id);
    setState(() {
      widget.task.isCompleted = !widget.task.isCompleted;
      for (var s in widget.task.subtasks) {
        s.isCompleted = widget.task.isCompleted;
      }
    });
    widget.onTaskUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final taskNumber = widget.task.id.substring(0, 4).toUpperCase();
    final totalSteps = widget.task.subtasks.length;
    final completedSteps = widget.task.completedSubtasksCount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Top Header: Back/ID & Action Icons (Screen 3 style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '#$taskNumber',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () {
                        widget.onDelete();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Main Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Category & Priority
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.lavender,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.task.category.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 16,
                            color: widget.task.priority == TaskPriority.high
                                ? AppColors.priorityHigh
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.task.priority.name[0].toUpperCase()}${widget.task.priority.name.substring(1)} priority',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.task.priority == TaskPriority.high
                                  ? AppColors.priorityHigh
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Title
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.25,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Time & Duration
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.task.startTime} - ${widget.task.endTime} • daily focus',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (widget.task.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.task.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Step-by-step checklist section (Key requested feature!)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step-by-Step Checklist ($completedSteps/$totalSteps)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isAddingStep ? Icons.close_rounded : Icons.add_circle_rounded,
                          color: AppColors.darkCard,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isAddingStep = !_isAddingStep;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Inline add step box
                  if (_isAddingStep)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newStepController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Enter next step/subtask...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 13),
                              ),
                              onSubmitted: (_) => _handleAddStep(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: AppColors.darkCard),
                            onPressed: _handleAddStep,
                          ),
                        ],
                      ),
                    ),

                  // List of subtask items
                  if (widget.task.subtasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'No step-by-step subtasks yet.\nTap + to break this task down!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...widget.task.subtasks.map((subtask) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: subtask.isCompleted
                              ? AppColors.limeLight.withValues(alpha: 0.5)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: subtask.isCompleted
                                ? AppColors.limeAccent.withValues(alpha: 0.5)
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _handleToggleSubtask(subtask),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: subtask.isCompleted
                                      ? AppColors.darkCard
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: subtask.isCompleted
                                        ? AppColors.darkCard
                                        : Colors.black45,
                                    width: 1.5,
                                  ),
                                ),
                                child: subtask.isCompleted
                                    ? const Icon(Icons.check_rounded, size: 14, color: AppColors.limeAccent)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: subtask.isCompleted
                                      ? AppColors.textMuted
                                      : AppColors.textDark,
                                  decoration: subtask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.black26),
                              onPressed: () => _handleDeleteSubtask(subtask),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Bottom Action Button (matching "Join meeting" pill button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkCard,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                onPressed: _handleToggleMainTask,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.task.isCompleted
                          ? Icons.replay_rounded
                          : Icons.check_circle_outline_rounded,
                      color: AppColors.limeAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.task.isCompleted
                          ? 'Mark Incomplete'
                          : 'Complete All Steps',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
