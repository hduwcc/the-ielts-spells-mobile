import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thành tựu & Huy hiệu'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hero Banner with Mountain Artwork
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF4EB), Color(0xFFFFEAD5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFDE4C3)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -15,
                    child: Opacity(
                      opacity: 0.85,
                      child: Image.asset(
                        'assets/images/achievement-mountain-design.png',
                        height: 95,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFD97706)),
                            SizedBox(width: 4),
                            Text(
                              'Cấp độ 5 • Phù thủy Tập sự',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Đã mở khóa 8 / 15 huy hiệu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF422006),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tiếp tục tích lũy XP để thăng hạng!',
                        style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '✦ Huy hiệu danh dự',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildBadgeCard(
              title: 'Ngọn lửa kiên định',
              description: 'Duy trì chuỗi học tập liên tục trong 14 ngày không đứt mạch.',
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.flameOrange,
              isUnlocked: true,
              rewardXp: '+100 XP',
              unlockedDate: 'Đã mở khóa hôm nay',
            ),
            const SizedBox(height: 12),

            _buildBadgeCard(
              title: 'Bậc thầy từ vựng SRS',
              description: 'Chinh phục 50 từ vựng ở trạng thái Đã thuộc (Mastered).',
              icon: Icons.auto_stories_rounded,
              iconColor: AppColors.freezeBlue,
              isUnlocked: true,
              rewardXp: '+150 XP',
              unlockedDate: 'Đã mở khóa ngày 05/11',
            ),
            const SizedBox(height: 12),

            _buildBadgeCard(
              title: 'Chiến binh Đấu trường',
              description: 'Đạt chuỗi Combo 15x liên tiếp trong Collocation Hunter.',
              icon: Icons.bolt_rounded,
              iconColor: AppColors.gold,
              isUnlocked: true,
              rewardXp: '+80 XP',
              unlockedDate: 'Đã mở khóa ngày 02/11',
            ),
            const SizedBox(height: 12),

            _buildBadgeCard(
              title: 'Nhà hùng biện Quick Speaking',
              description: 'Thực hành nói 10 chủ đề Speaking liên tiếp với AI.',
              icon: Icons.mic_rounded,
              iconColor: AppColors.primary,
              isUnlocked: false,
              progress: 0.6,
              progressText: '6 / 10 bài nói',
              rewardXp: '+200 XP',
            ),
            const SizedBox(height: 12),

            _buildBadgeCard(
              title: 'Đỉnh cao Lớp học',
              description: 'Lọt vào Top 3 bảng xếp hạng tuần của lớp học IELTS.',
              icon: Icons.military_tech_rounded,
              iconColor: const Color(0xFFD97706),
              isUnlocked: false,
              progress: 0.33,
              progressText: 'Hạng 3 hiện tại',
              rewardXp: '+250 XP',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isUnlocked,
    required String rewardXp,
    String? unlockedDate,
    double? progress,
    String? progressText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked ? iconColor.withOpacity(0.3) : AppColors.borderCard,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? iconColor.withOpacity(0.12) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? iconColor : const Color(0xFF9CA3AF),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? AppColors.textPrimary : const Color(0xFF6B7280),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUnlocked ? AppColors.primarySubtle : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rewardXp,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.primary : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 8),
                if (isUnlocked && unlockedDate != null)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        unlockedDate,
                        style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                else if (progress != null && progressText != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFF3E8EC),
                          valueColor: AlwaysStoppedAnimation(iconColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        progressText,
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
