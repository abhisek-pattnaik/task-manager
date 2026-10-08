import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg;
    Color textColor;
    Color pillBg;
    Color pillText;

    switch (task.colorStyle) {
      case 'lavender':
        cardBg = AppColors.lavender;
        textColor = AppColors.textDark;
        pillBg = Colors.white.withValues(alpha: 0.65);
        pillText = AppColors.textDark;
        break;
      case 'yellow':
        cardBg = AppColors.limeAccent;
        textColor = AppColors.textDark;
        pillBg = Colors.black.withValues(alpha: 0.08);
        pillText = AppColors.textDark;
        break;
      case 'dark':
        cardBg = AppColors.darkCard;
        textColor = AppColors.textLight;
        pillBg = Colors.white.withValues(alpha: 0.12);
        pillText = Colors.white;
        break;
      case 'mint':
      default:
        cardBg = AppColors.mint;
        textColor = AppColors.textDark;
        pillBg = Colors.white.withValues(alpha: 0.7);
        pillText = AppColors.textDark;
        break;
    }

    final hasSubtasks = task.subtasks.isNotEmpty;
    final totalSteps = task.subtasks.length;
    final completedSteps = task.completedSubtasksCount;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Pill & Priority Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    task.category.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: pillText,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? (task.colorStyle == 'dark' ? AppColors.limeAccent : AppColors.darkCard)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                            ? Colors.transparent
                            : (task.colorStyle == 'dark' ? Colors.white60 : Colors.black45),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: task.isCompleted
                          ? (task.colorStyle == 'dark' ? AppColors.darkCard : Colors.white)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              task.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Time & Duration
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: textColor.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.startTime} - ${task.endTime}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            // Step Checklist Progress Bar if subtasks exist
            if (hasSubtasks) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedSteps of $totalSteps steps done',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.75),
                    ),
                  ),
                  Text(
                    '${(task.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: textColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    task.colorStyle == 'dark' ? AppColors.limeAccent : AppColors.darkCard,
                  ),
                  minHeight: 5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
