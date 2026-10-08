import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'task_card.dart';

class TimelineView extends StatelessWidget {
  final List<TaskModel> tasks;
  final ValueChanged<TaskModel> onTaskTap;
  final ValueChanged<TaskModel> onToggleComplete;

  const TimelineView({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final hours = [
      '8 AM',
      '9 AM',
      '10 AM',
      '11 AM',
      '12 PM',
      '1 PM',
      '2 PM',
      '3 PM',
      '4 PM',
      '5 PM',
      '6 PM',
      '7 PM',
      '8 PM',
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 90),
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hourStr = hours[index];
        // Match tasks that fall in this hour slot
        final slotTasks = tasks.where((t) {
          final startLower = t.startTime.toLowerCase();
          final hourNum = hourStr.split(' ')[0];
          final period = hourStr.split(' ')[1].toLowerCase();
          return (startLower.contains(hourNum) && startLower.contains(period)) ||
              (index == 0 && startLower.contains('08:')) ||
              (index == 1 && startLower.contains('09:')) ||
              (index == 2 && startLower.contains('10:')) ||
              (index == 3 && startLower.contains('11:')) ||
              (index == 4 && startLower.contains('12:')) ||
              (index == 5 && startLower.contains('01:') || startLower.contains('1:')) ||
              (index == 6 && startLower.contains('02:') || startLower.contains('2:')) ||
              (index == 7 && startLower.contains('03:') || startLower.contains('3:')) ||
              (index == 8 && startLower.contains('04:') || startLower.contains('4:')) ||
              (index == 9 && startLower.contains('05:') || startLower.contains('5:')) ||
              (index == 10 && startLower.contains('06:') || startLower.contains('6:')) ||
              (index == 11 && startLower.contains('07:') || startLower.contains('7:')) ||
              (index == 12 && startLower.contains('08:') && startLower.contains('pm'));
        }).toList();

        final isCurrentTimeSlot = index == 1; // 9 AM slot indicator like screenshot

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hour label
              SizedBox(
                width: 54,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hourStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),

              // Divider Line & Timeline Content
              Expanded(
                child: Stack(
                  children: [
                    // Horizontal guideline
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: AppColors.border,
                      ),
                    ),

                    // Current Time Indicator Line (Like screenshot)
                    if (isCurrentTimeSlot)
                      Positioned(
                        top: 28,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.darkCard,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: AppColors.darkCard,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Tasks inside slot
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 10),
                      child: slotTasks.isEmpty
                          ? const SizedBox(height: 48)
                          : Column(
                              children: slotTasks.map((task) {
                                return TaskCard(
                                  task: task,
                                  onTap: () => onTaskTap(task),
                                  onToggleComplete: () => onToggleComplete(task),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
