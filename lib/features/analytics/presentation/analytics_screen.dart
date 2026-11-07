import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thống kê học tập'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Weekly Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0F3), Color(0xFFFFE3E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng quan tuần này',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Icon(Icons.insights_rounded, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricItem('145 phút', 'Thời gian học', Icons.timer_outlined),
                      _buildMetricItem('48 từ', 'Từ vựng thuộc', Icons.auto_stories_outlined),
                      _buildMetricItem('14 ngày', 'Chuỗi Streak', Icons.local_fire_department_outlined),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Study Activity Bar Chart
            const Text(
              '✦ Hoạt động 7 ngày gần nhất',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBarCol('T2', 25, false),
                      _buildBarCol('T3', 35, false),
                      _buildBarCol('T4', 20, false),
                      _buildBarCol('T5', 40, false),
                      _buildBarCol('T6', 15, false),
                      _buildBarCol('T7', 45, false),
                      _buildBarCol('CN', 35, true), // Today
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mục tiêu mỗi ngày: 30 phút', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('Đạt 85% tuần', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SRS Retention Distribution
            const Text(
              '✦ Phân bố Sổ từ SRS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                children: [
                  _buildProgressRow('Đã thuộc (Mastered)', 0.45, '54 từ', AppColors.freezeBlue),
                  const SizedBox(height: 14),
                  _buildProgressRow('Đang ôn lại (Reviewing)', 0.30, '36 từ', AppColors.success),
                  const SizedBox(height: 14),
                  _buildProgressRow('Đang học (Learning)', 0.15, '18 từ', AppColors.warning),
                  const SizedBox(height: 14),
                  _buildProgressRow('Từ mới (New)', 0.10, '12 từ', AppColors.error),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Band Progress
            const Text(
              '✦ Tiến độ mục tiêu IELTS Band 7.5',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                children: [
                  _buildSkillRow('Reading', 'Band 7.0 / 7.5', 0.85),
                  const SizedBox(height: 12),
                  _buildSkillRow('Listening', 'Band 6.5 / 7.5', 0.75),
                  const SizedBox(height: 12),
                  _buildSkillRow('Writing', 'Band 6.0 / 7.0', 0.65),
                  const SizedBox(height: 12),
                  _buildSkillRow('Speaking', 'Band 6.5 / 7.5', 0.75),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String val, String label, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCol(String day, int minutes, bool isToday) {
    final double height = (minutes / 50.0) * 100.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$minutes\'',
          style: TextStyle(
            fontSize: 10,
            color: isToday ? AppColors.primary : AppColors.textTertiary,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 22,
          height: height.clamp(16.0, 100.0),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : const Color(0xFFF2D5DD),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isToday ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String label, double percent, String count, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 7,
            backgroundColor: const Color(0xFFF3E8EC),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillRow(String skill, String band, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(skill, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(band, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFF3E8EC),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
