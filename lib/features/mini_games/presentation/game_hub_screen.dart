import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../data/mini_games_dataset.dart';
import 'collocation_hunter_screen.dart';
import 'grammar_detective_screen.dart';
import 'speed_vocab_screen.dart';

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});

  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> {
  GameDifficulty _selectedDifficulty = GameDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đấu trường Mini-Games'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Rèn phản xạ từ vựng & ngữ pháp 3-5 phút mỗi ngày:',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Difficulty Selector Pills
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Row(
                children: GameDifficulty.values.map((diff) {
                  final isSelected = _selectedDifficulty == diff;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticService.selection();
                        setState(() => _selectedDifficulty = diff);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            diff.shortLabel,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Cấp độ: ${_selectedDifficulty.label}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),
            _buildGameCard(
              context: context,
              title: 'Collocation Hunter',
              badge: '30 GIÂY • NỐI CỤM TỪ',
              badgeColor: AppColors.primaryLight,
              description:
                  'Nối nhanh 2 nửa collocation học thuật. Kích hoạt Fever Mode nhân ba điểm số!',
              icon: Icons.link_rounded,
              accentColor: AppColors.primary,
              onTap: () {
                HapticService.medium();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CollocationHunterScreen(difficulty: _selectedDifficulty),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context: context,
              title: 'Grammar Detective',
              badge: '10S/CÂU • SĂN LỖI SAI',
              badgeColor: AppColors.gold,
              description:
                  'Chạm thẳng vào lỗi ngữ pháp thường gặp trong các bài viết thật để nhận giải thích chi tiết.',
              icon: Icons.search_rounded,
              accentColor: AppColors.gold,
              onTap: () {
                HapticService.medium();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrammarDetectiveScreen(difficulty: _selectedDifficulty),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context: context,
              title: 'Speed Vocab',
              badge: '5S • PHẢN XẠ NGHĨA TỪ',
              badgeColor: AppColors.flameOrange,
              description:
                  'Phản xạ thần tốc nghĩa từ vựng tiếng Việt. Trả lời dưới 1.5s để nhận thêm điểm thưởng Speed Bonus.',
              icon: Icons.bolt_rounded,
              accentColor: AppColors.flameOrange,
              onTap: () {
                HapticService.medium();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeedVocabScreen(difficulty: _selectedDifficulty),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderCard, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
