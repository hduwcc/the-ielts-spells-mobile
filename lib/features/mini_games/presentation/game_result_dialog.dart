import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';

class GameResultDialog extends StatelessWidget {
  final String gameTitle;
  final int score;
  final int maxCombo;
  final int xpEarned;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const GameResultDialog({
    super.key,
    required this.gameTitle,
    required this.score,
    required this.maxCombo,
    required this.xpEarned,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    AudioService.playLevelUp();
    HapticService.heavy();

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.gold,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Hoàn thành $gameTitle!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Thói quen học tập của bạn đã được ghi nhận vào Streak!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Điểm số', '$score', AppColors.primaryLight),
                    _buildStatItem('Max Combo', '$maxCombo🔥', AppColors.flameOrange),
                    _buildStatItem('Kinh nghiệm', '+$xpEarned XP', AppColors.gold),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Chơi lại ván mới'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onExit,
                  child: const Text('Về trang chủ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
