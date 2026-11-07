import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../habit_streak/models/streak_model.dart';
import '../../habit_streak/presentation/streak_calendar_modal.dart';
import '../../leaderboard/presentation/leaderboard_screen.dart';
import '../../mini_games/presentation/game_hub_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../quick_speaking/presentation/quick_speaking_screen.dart';
import '../../vocab_srs/presentation/srs_deck_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  StreakModel? _streak;
  String _enrolledCourseCode = 'IELTS 2026-0011';
  int _todayXp = 35;
  int _dailyGoalXp = 100;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAppAndLoadData();
  }

  Future<void> _initAppAndLoadData() async {
    setState(() => _isLoading = true);
    await AuthService.init();
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final data = await ApiClient.getDashboard();

    if (mounted) {
      setState(() {
        _streak = StreakModel.fromJson(data['streak'] as Map<String, dynamic>);
        _enrolledCourseCode = data['enrolledCourseCode'] ?? 'IELTS 2026-0011';
        _todayXp = _streak?.todayXp ?? 35;
        _dailyGoalXp = _streak?.dailyGoalXp ?? 100;
        _isLoading = false;
      });
    }
  }

  void _openStreakDetail() {
    if (_streak == null) return;
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreakCalendarModal(
        streak: _streak!,
        onStreakUpdated: _loadDashboardData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomeFeedTab(),
          const AnalyticsScreen(),
          const AchievementsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeFeedTab() {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadDashboardData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // 1. App Header: Logo + Title + Notifications + Streak Pill
            _buildTopAppBar(),
            const SizedBox(height: 18),

            // 2. Hero Card: "Mục tiêu học tập hôm nay"
            _buildHeroGoalCard(),
            const SizedBox(height: 24),

            // 3. Section Heading: "✦ Khám phá các tính năng nổi bật"
            const Row(
              children: [
                Text(
                  '✦',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Khám phá các tính năng nổi bật',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Feature Card 1: Sổ từ Thông minh (SRS)
            _buildActionFeatureCard(
              iconWidget: const Icon(Icons.style_rounded, color: AppColors.primary, size: 26),
              iconBgColor: const Color(0xFFFFE8EE),
              pillText: '⏱ 5 – 10 Phút',
              pillBgColor: const Color(0xFFEFF6FF),
              pillTextColor: const Color(0xFF2563EB),
              title: 'Sổ từ Thông minh (SRS)',
              subtitle: 'Luyện từ vựng theo chu kỳ lặp lại, ghi nhớ vượt trội với phương pháp Spaced Repetition.',
              onTap: () {
                HapticService.selection();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SrsDeckScreen()),
                ).then((_) => _loadDashboardData());
              },
            ),
            const SizedBox(height: 14),

            // 5. Feature Card 2: Đấu trường Mini-Games
            _buildActionFeatureCard(
              iconWidget: const Icon(Icons.sports_esports_rounded, color: Color(0xFFFF7A45), size: 26),
              iconBgColor: const Color(0xFFFFF0E6),
              pillText: '🎴 Game hóa • Thử thách',
              pillBgColor: const Color(0xFFFFF7ED),
              pillTextColor: const Color(0xFFEA580C),
              title: 'Đấu trường Mini-Games',
              subtitle: 'Rèn luyện phản xạ qua các trò chơi thú vị: Matching, Cloze, Quiz,...',
              onTap: () {
                HapticService.selection();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameHubScreen()),
                ).then((_) => _loadDashboardData());
              },
            ),
            const SizedBox(height: 14),

            // 6. Feature Card 3: Luyện Quick Speaking AI
            _buildActionFeatureCard(
              iconWidget: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 26),
              iconBgColor: const Color(0xFFFFE8EE),
              pillText: '⏱ Công nghệ AI',
              pillBgColor: const Color(0xFFFDF2F8),
              pillTextColor: const Color(0xFFDB2777),
              title: 'Luyện Quick Speaking AI',
              subtitle: 'Thực hành nói tiếng Anh với AI, nhận phản hồi chi tiết và cải thiện phát âm.',
              onTap: () {
                HapticService.selection();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuickSpeakingScreen()),
                ).then((_) => _loadDashboardData());
              },
            ),
            const SizedBox(height: 14),

            // 7. Feature Card 4: Bảng xếp hạng Lớp IELTS [Code] (Gold Card)
            _buildLeaderboardGoldCard(),
            const SizedBox(height: 20),

            // 8. Bottom Mountain Decoration Artwork
            Center(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/achievement-mountain-design.png',
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Top App Bar matching Screenshot ---
  Widget _buildTopAppBar() {
    final streakDays = _streak?.currentStreak ?? 14;

    return Row(
      children: [
        // Official Web Logo Circular Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF7CCD6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Text(
                  'S',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Title and Learning workspace subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The IELTS Spells',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Learning workspace',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Notification Bell Icon with Badge "3"
        GestureDetector(
          onTap: () {
            HapticService.selection();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bạn có 3 thông báo bài học mới từ giáo viên.')),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFDEFF2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF2B1F24),
                  size: 22,
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE03E5D),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Streak Flame Pill Badge
        GestureDetector(
          onTap: _openStreakDetail,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF45B69), Color(0xFFFCA385)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF45B69).withOpacity(0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$streakDays',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Hero Card: "Mục tiêu học tập hôm nay" with Magic Book ---
  Widget _buildHeroGoalCard() {
    final double progress = (_dailyGoalXp > 0) ? (_todayXp / _dailyGoalXp).clamp(0.0, 1.0) : 0.35;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F3), Color(0xFFFFE3E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD8DF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Magic Book Artwork on the right side
          Positioned(
            right: 0,
            top: -2,
            bottom: -2,
            child: Image.asset(
              'assets/images/hero-book-design.png',
              width: 105,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // Content on the left side
          Padding(
            padding: const EdgeInsets.only(right: 95.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Mục tiêu học tập hôm nay',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_todayXp / $_dailyGoalXp XP',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Rounded Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7.5,
                    backgroundColor: const Color(0xFFF2D5DD),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFD1456D)),
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  '✨ Tiếp tục học tập để chinh phục mục tiêu của bạn!',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF66555C),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SrsDeckScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Khám phá',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC84062),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: Color(0xFFC84062),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Feature Card Item matching screenshot ---
  Widget _buildActionFeatureCard({
    required Widget iconWidget,
    required Color iconBgColor,
    required String pillText,
    required Color pillBgColor,
    required Color pillTextColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1E6E8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: pillBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pillText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: pillTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7D6E74),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            // Right Chevron
            const Padding(
              padding: EdgeInsets.only(top: 14.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF9D8C92),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Leaderboard Gold Card matching screenshot ---
  Widget _buildLeaderboardGoldCard() {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E7), Color(0xFFFFEBD0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDE4C3), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Trophy Icon
            const Text(
              '🏆',
              style: TextStyle(fontSize: 34),
            ),
            const SizedBox(width: 12),

            // Center Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bảng xếp hạng Lớp $_enrolledCourseCode',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF422006),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Rèn luyện cùng bạn bè, chinh phục đỉnh cao!',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF78350F),
                    ),
                  ),
                ],
              ),
            ),

            // Mountain Flag Artwork + Pink Chevron Circle
            Row(
              children: [
                Image.asset(
                  'assets/images/achievement-mountain-design.png',
                  height: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8B4C0),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Color(0xFFC84062),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Bottom Navigation Bar with 4 Tabs matching Screenshot ---
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderCard.withOpacity(0.8), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Trang chủ'),
              _buildNavItem(1, Icons.bar_chart_rounded, 'Thống kê'),
              _buildNavItem(2, Icons.star_rounded, 'Thành tựu'),
              _buildNavItem(3, Icons.person_rounded, 'Cá nhân'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() => _currentTabIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container (Pill background for active Home)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          // Rose active underline bar
          Container(
            width: 24,
            height: 2.5,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
