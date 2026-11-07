import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/streak_model.dart';
import 'streak_calendar_modal.dart';

class StreakFlameWidget extends StatefulWidget {
  final StreakModel streak;
  final VoidCallback? onStreakUpdated;

  const StreakFlameWidget({
    super.key,
    required this.streak,
    this.onStreakUpdated,
  });

  @override
  State<StreakFlameWidget> createState() => _StreakFlameWidgetState();
}

class _StreakFlameWidgetState extends State<StreakFlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openCalendarModal() {
    HapticService.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreakCalendarModal(
        streak: widget.streak,
        onStreakUpdated: widget.onStreakUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLit = widget.streak.currentStreak > 0;
    final Color flameColor = isLit ? AppColors.flameOrange : AppColors.textTertiary;

    return GestureDetector(
      onTap: _openCalendarModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isLit ? flameColor.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLit ? flameColor.withOpacity(0.4) : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isLit ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: flameColor,
                    size: 22,
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.streak.currentStreak}',
              style: TextStyle(
                color: isLit ? flameColor : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
