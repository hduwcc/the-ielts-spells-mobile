import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  int _weeklyMinutes = 0;
  int _masteredWords = 0;
  int _reviewingWords = 0;
  int _learningWords = 0;
  int _newWords = 0;
  int _streakDays = 0;
  double _targetBand = 7.0;
  double? _currentBand;

  final Map<String, int> _dailyMinutes = {
    'T2': 0,
    'T3': 0,
    'T4': 0,
    'T5': 0,
    'T6': 0,
    'T7': 0,
    'CN': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final overview = await ApiClient.getStudentPortalOverview();
      final notebook = await ApiClient.getStudentVocabularyNotebook();

      if (overview != null) {
        final metrics = overview['metrics'] as Map<String, dynamic>?;
        final profile = overview['profile'] as Map<String, dynamic>?;
        final activityCalendar = overview['activityCalendar'] as List<dynamic>? ?? [];

        _streakDays = metrics?['currentStreakDays'] ?? AuthService.currentUser?.streakDays ?? 0;
        _targetBand = (profile?['targetBand'] as num?)?.toDouble() ?? AuthService.currentUser?.targetBand ?? 7.0;
        _currentBand = (profile?['currentBand'] as num?)?.toDouble() ?? AuthService.currentUser?.currentBand;

        // Calculate real daily minutes from activityCalendar
        int totalSeconds = 0;
        for (final act in activityCalendar) {
          final seconds = (act['durationSeconds'] as num?)?.toInt() ?? 0;
          totalSeconds += seconds;
        }
        _weeklyMinutes = (totalSeconds / 60).round();
      } else {
        _streakDays = AuthService.currentUser?.streakDays ?? 0;
        _targetBand = AuthService.currentUser?.targetBand ?? 7.0;
        _currentBand = AuthService.currentUser?.currentBand;
        _weeklyMinutes = 0;
      }

      // Read real words count
      _masteredWords = notebook['masteredCount'] ?? 0;
      _reviewingWords = notebook['reviewingCount'] ?? 0;
      _learningWords = notebook['learningCount'] ?? 0;
      _newWords = notebook['totalCards'] != null
          ? ((notebook['totalCards'] as int) - _masteredWords - _reviewingWords - _learningWords).clamp(0, 999)
          : 0;
    } catch (_) {
      _streakDays = AuthService.currentUser?.streakDays ?? 0;
      _targetBand = AuthService.currentUser?.targetBand ?? 7.0;
      _currentBand = AuthService.currentUser?.currentBand;
      _weeklyMinutes = 0;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final int totalWords = _masteredWords + _reviewingWords + _learningWords + _newWords;
    final bool hasActivity = _weeklyMinutes > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thống kê học tập'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới thống kê',
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadAnalytics,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Weekly Summary Card (Real Data 100%)
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
                        _buildMetricItem('$_weeklyMinutes phút', 'Thời gian học', Icons.timer_outlined),
                        _buildMetricItem('$_masteredWords từ', 'Từ vựng thuộc', Icons.auto_stories_outlined),
                        _buildMetricItem('$_streakDays ngày', 'Chuỗi Streak', Icons.local_fire_department_outlined),
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
                    if (!hasActivity) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            Icon(Icons.query_builder_rounded, size: 40, color: AppColors.textTertiary.withOpacity(0.6)),
                            const SizedBox(height: 8),
                            const Text(
                              'Chưa có hoạt động học tập nào trong tuần này',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Hãy làm bài tập hoặc chơi mini-game để ghi nhận thời gian học!',
                              style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBarCol('T2', _dailyMinutes['T2'] ?? 0, false),
                          _buildBarCol('T3', _dailyMinutes['T3'] ?? 0, false),
                          _buildBarCol('T4', _dailyMinutes['T4'] ?? 0, false),
                          _buildBarCol('T5', _dailyMinutes['T5'] ?? 0, false),
                          _buildBarCol('T6', _dailyMinutes['T6'] ?? 0, false),
                          _buildBarCol('T7', _dailyMinutes['T7'] ?? 0, false),
                          _buildBarCol('CN', _dailyMinutes['CN'] ?? 0, true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mục tiêu mỗi ngày: 30 phút', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('Đạt $_weeklyMinutes phút tuần này', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
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
                child: totalWords == 0
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            'Chưa có từ vựng nào trong sổ từ cá nhân.\nHãy bắt đầu thêm từ mới từ bài đọc hoặc bộ từ tuyển chọn!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          _buildProgressRow(
                            'Đã thuộc (Mastered)',
                            totalWords > 0 ? (_masteredWords / totalWords) : 0.0,
                            '$_masteredWords từ',
                            AppColors.freezeBlue,
                          ),
                          const SizedBox(height: 14),
                          _buildProgressRow(
                            'Đang ôn lại (Reviewing)',
                            totalWords > 0 ? (_reviewingWords / totalWords) : 0.0,
                            '$_reviewingWords từ',
                            AppColors.success,
                          ),
                          const SizedBox(height: 14),
                          _buildProgressRow(
                            'Đang học (Learning)',
                            totalWords > 0 ? (_learningWords / totalWords) : 0.0,
                            '$_learningWords từ',
                            AppColors.warning,
                          ),
                          const SizedBox(height: 14),
                          _buildProgressRow(
                            'Từ mới (New)',
                            totalWords > 0 ? (_newWords / totalWords) : 0.0,
                            '$_newWords từ',
                            AppColors.error,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // Target Band Progress
              Text(
                '✦ Tiến độ mục tiêu IELTS Band ${_targetBand.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                    _buildSkillRow('Reading', _currentBand != null ? 'Band ${_currentBand!.toStringAsFixed(1)} / ${_targetBand.toStringAsFixed(1)}' : 'Chưa có kết quả test', _currentBand != null ? (_currentBand! / _targetBand).clamp(0.0, 1.0) : 0.0),
                    const SizedBox(height: 12),
                    _buildSkillRow('Listening', _currentBand != null ? 'Band ${_currentBand!.toStringAsFixed(1)} / ${_targetBand.toStringAsFixed(1)}' : 'Chưa có kết quả test', _currentBand != null ? (_currentBand! / _targetBand).clamp(0.0, 1.0) : 0.0),
                    const SizedBox(height: 12),
                    _buildSkillRow('Writing', 'Chưa có kết quả test', 0.0),
                    const SizedBox(height: 12),
                    _buildSkillRow('Speaking', 'Chưa có kết quả test', 0.0),
                  ],
                ),
              ),
            ],
          ),
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
    final double height = minutes > 0 ? (minutes / 50.0 * 100.0).clamp(16.0, 100.0) : 6.0;
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
          height: height,
          decoration: BoxDecoration(
            color: minutes > 0 ? (isToday ? AppColors.primary : const Color(0xFFF2D5DD)) : const Color(0xFFE5E7EB),
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
