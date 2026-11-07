import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/streak_model.dart';

class FreezeShieldDialog extends StatelessWidget {
  final StreakModel streak;

  const FreezeShieldDialog({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    const int costXp = 200;
    final bool canAfford = streak.totalXp >= costXp;
    final bool isMaxShields = streak.freezeShields >= streak.maxFreezeShields;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.freezeBlue.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.freezeBlue,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Khiên Đóng Băng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bảo vệ ngọn lửa Streak của bạn không bị tắt nếu bạn lỡ quên học trong một ngày.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Số khiên hiện có:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  Text(
                    '${streak.freezeShields} / ${streak.maxFreezeShields}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.freezeBlue,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.freezeBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: (isMaxShields || !canAfford)
                    ? null
                    : () {
                        HapticService.heavy();
                        AudioService.playLevelUp();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã kích hoạt thêm 1 Khiên Băng thành công! (-200 XP)'),
                            backgroundColor: AppColors.freezeBlue,
                          ),
                        );
                      },
                icon: const Icon(Icons.bolt_rounded),
                label: Text(
                  isMaxShields
                      ? 'Đã đạt tối đa khiên'
                      : 'Đổi khiên (200 XP)',
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
