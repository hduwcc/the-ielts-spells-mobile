import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/mock_data.dart';
import '../models/streak_model.dart';
import 'freeze_shield_dialog.dart';

class StreakCalendarModal extends StatelessWidget {
  final StreakModel streak;
  final VoidCallback? onStreakUpdated;

  const StreakCalendarModal({
    super.key,
    required this.streak,
    this.onStreakUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final history = MockData.streakCalendarHistory;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.flameOrange,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chuỗi ${streak.currentStreak} ngày',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Kỷ lục dài nhất: ${streak.longestStreak} ngày',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Streak Status Cards Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Khiên bảo vệ',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.shield_rounded, color: AppColors.freezeBlue, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '${streak.freezeShields} / ${streak.maxFreezeShields}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticService.light();
                      showDialog(
                        context: context,
                        builder: (_) => FreezeShieldDialog(streak: streak),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.freezeBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.freezeBlue.withOpacity(0.4)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kích hoạt khiên',
                            style: TextStyle(fontSize: 12, color: AppColors.freezeBlue),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.add_circle_outline_rounded,
                                  color: AppColors.freezeBlue, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Nạp khiên (200 XP)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Nhật ký hoạt động tháng này',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Calendar Grid Visualization
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: history.map((item) {
                final status = item['status'] as String;
                final isCompleted = status == 'COMPLETED';
                final isFrozen = status == 'FROZEN';

                Color dotColor = AppColors.border;
                IconData? icon;
                if (isCompleted) {
                  dotColor = AppColors.flameOrange;
                  icon = Icons.local_fire_department_rounded;
                } else if (isFrozen) {
                  dotColor = AppColors.freezeBlue;
                  icon = Icons.shield_rounded;
                }

                return Tooltip(
                  message: '${item['date']}: $status (${item['xp']} XP)',
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: dotColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: dotColor, width: 1.5),
                    ),
                    child: icon != null
                        ? Icon(icon, color: dotColor, size: 20)
                        : const SizedBox(),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.flameOrange, 'Đã học'),
                const SizedBox(width: 20),
                _buildLegendItem(AppColors.freezeBlue, 'Khiên bảo vệ (Đóng băng)'),
                const SizedBox(width: 20),
                _buildLegendItem(AppColors.borderLight, 'Chưa học'),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
