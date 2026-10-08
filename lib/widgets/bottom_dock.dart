import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddTask;

  const BottomDock({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDockIcon(
            icon: Icons.checklist_rounded,
            isSelected: currentIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: onAddTask,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.limeAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.darkCard,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          _buildDockIcon(
            icon: Icons.calendar_today_rounded,
            isSelected: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDockIcon({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.limeAccent : Colors.white60,
          size: 22,
        ),
      ),
    );
  }
}
