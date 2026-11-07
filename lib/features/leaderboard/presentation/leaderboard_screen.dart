import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../models/leaderboard_models.dart';
import 'podium_top3_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<LeaderboardEntry> _courseList = [];
  List<LeaderboardEntry> _globalList = [];
  String _courseName = 'IELTS Chuyên sâu L/R 6.5+ (LR-2605-001)';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final courseData = await ApiClient.getLeaderboard(scope: 'COURSE');
    final globalData = await ApiClient.getLeaderboard(scope: 'GLOBAL');

    final rawCourse = (courseData['leaderboard'] as List? ?? [])
        .map((j) => LeaderboardEntry.fromJson(j as Map<String, dynamic>))
        .toList();
    final rawGlobal = (globalData['leaderboard'] as List? ?? [])
        .map((j) => LeaderboardEntry.fromJson(j as Map<String, dynamic>))
        .toList();

    setState(() {
      _courseList = rawCourse;
      _globalList = rawGlobal;
      _courseName = courseData['courseName'] ?? _courseName;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bảng Xếp Hạng Tuần'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Cùng Lớp Học'),
            Tab(text: 'Toàn Trung Tâm'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(
                  entries: _courseList,
                  headerSubtext: _courseName,
                ),
                _buildLeaderboardTab(
                  entries: _globalList,
                  headerSubtext: 'Top 50 học viên xuất sắc nhất tuần',
                ),
              ],
            ),
    );
  }

  Widget _buildLeaderboardTab({
    required List<LeaderboardEntry> entries,
    required String headerSubtext,
  }) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('Chưa có dữ liệu bảng xếp hạng.'),
      );
    }

    final top3 = entries.take(3).toList();
    final remaining = entries.skip(3).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primaryLight, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      headerSubtext,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (top3.length >= 3) PodiumTop3Widget(top3: top3),
          const SizedBox(height: 8),
          ...remaining.map((entry) => _buildRankTile(entry)),
        ],
      ),
    );
  }

  Widget _buildRankTile(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isMe ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isMe ? AppColors.primaryLight : AppColors.border,
          width: entry.isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: entry.isMe ? AppColors.primaryLight : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceElevated,
            child: Text(
              entry.name.isNotEmpty ? entry.name[0] : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: entry.isMe ? FontWeight.bold : FontWeight.w600,
                    color: entry.isMe ? AppColors.primaryLight : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '🔥 ${entry.streak} ngày streak',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}
