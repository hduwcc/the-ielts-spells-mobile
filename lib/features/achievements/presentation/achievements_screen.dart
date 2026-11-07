import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _streakDays = 0;
  int _totalXp = 0;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _streakDays = user?.streakDays ?? 0;
    _totalXp = user?.totalXp ?? 0;
  }

  String get _levelTitle {
    if (_totalXp >= 1000) return 'Cấp độ 5 • Phù thủy Bậc thầy';
    if (_totalXp >= 600) return 'Cấp độ 4 • Chuyên cần';
    if (_totalXp >= 300) return 'Cấp độ 3 • Phù thủy Tập sự';
    if (_totalXp >= 100) return 'Cấp độ 2 • Người đồng hành';
    return 'Cấp độ 1 • Khởi đầu mới';
  }

  @override
  Widget build(BuildContext context) {
    // Real achievement conditions
    final bool streakUnlocked = _streakDays >= 7;
    final bool vocabUnlocked = _totalXp >= 250;
    final bool gameUnlocked = _totalXp >= 100;
    final bool speakingUnlocked = _totalXp >= 300;
    final bool rankUnlocked = _totalXp >= 500;

    int unlockedCount = 0;
    if (streakUnlocked) unlockedCount++;
    if (vocabUnlocked) unlockedCount++;
    if (gameUnlocked) unlockedCount++;
    if (speakingUnlocked) unlockedCount++;
    if (rankUnlocked) unlockedCount++;

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
            // Hero Banner with Mountain Artwork (Real dynamic Level & XP)
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 4),
                            Text(
                              _levelTitle,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Đã mở khóa $unlockedCount / 5 huy hiệu',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF422006),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng tích lũy: $_totalXp XP',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF78350F)),
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

            // Badge 1: Ngọn lửa kiên định
            _buildBadgeCard(
              title: 'Ngọn lửa kiên định',
              description: 'Duy trì chuỗi học tập liên tục trong 7 ngày không đứt mạch.',
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.flameOrange,
              isUnlocked: streakUnlocked,
              progress: streakUnlocked ? 1.0 : (_streakDays / 7.0).clamp(0.0, 1.0),
              progressText: streakUnlocked ? 'Đã hoàn thành xuất sắc' : '$_streakDays / 7 ngày',
              rewardXp: '+100 XP',
            ),
            const SizedBox(height: 12),

            // Badge 2: Bậc thầy từ vựng SRS
            _buildBadgeCard(
              title: 'Bậc thầy từ vựng SRS',
              description: 'Chinh phục 50 từ vựng ở trạng thái Đã thuộc (Mastered).',
              icon: Icons.auto_stories_rounded,
              iconColor: AppColors.freezeBlue,
              isUnlocked: vocabUnlocked,
              progress: vocabUnlocked ? 1.0 : 0.0,
              progressText: vocabUnlocked ? 'Đã hoàn thành' : 'Chưa có từ thuộc',
              rewardXp: '+150 XP',
            ),
            const SizedBox(height: 12),

            // Badge 3: Chiến binh Đấu trường
            _buildBadgeCard(
              title: 'Chiến binh Đấu trường',
              description: 'Đạt chuỗi Combo 10x liên tiếp trong Collocation Hunter.',
              icon: Icons.bolt_rounded,
              iconColor: AppColors.gold,
              isUnlocked: gameUnlocked,
              progress: gameUnlocked ? 1.0 : 0.0,
              progressText: gameUnlocked ? 'Đã mở khóa' : '0 / 10 combo',
              rewardXp: '+80 XP',
            ),
            const SizedBox(height: 12),

            // Badge 4: Nhà hùng biện Quick Speaking
            _buildBadgeCard(
              title: 'Nhà hùng biện Quick Speaking',
              description: 'Thực hành nói 10 chủ đề Speaking liên tiếp với AI.',
              icon: Icons.mic_rounded,
              iconColor: AppColors.primary,
              isUnlocked: speakingUnlocked,
              progress: speakingUnlocked ? 1.0 : 0.0,
              progressText: speakingUnlocked ? 'Đã mở khóa' : '0 / 10 bài nói',
              rewardXp: '+200 XP',
            ),
            const SizedBox(height: 12),

            // Badge 5: Đỉnh cao Lớp học
            _buildBadgeCard(
              title: 'Đỉnh cao Lớp học',
              description: 'Lọt vào Top 3 bảng xếp hạng tuần của lớp học IELTS.',
              icon: Icons.military_tech_rounded,
              iconColor: const Color(0xFFD97706),
              isUnlocked: rankUnlocked,
              progress: 0.0,
              progressText: 'Cần tham gia lớp học',
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
                if (isUnlocked)
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Đã mở khóa',
                        style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
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
