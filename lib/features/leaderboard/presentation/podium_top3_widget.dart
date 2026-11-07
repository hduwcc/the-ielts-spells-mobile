import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/leaderboard_models.dart';

class PodiumTop3Widget extends StatelessWidget {
  final List<LeaderboardEntry> top3;

  const PodiumTop3Widget({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) return const SizedBox();

    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          _buildPodiumColumn(
            entry: second,
            rank: 2,
            height: 110,
            color: AppColors.silver,
          ),
          const SizedBox(width: 12),
          // 1st Place (Gold)
          _buildPodiumColumn(
            entry: first,
            rank: 1,
            height: 140,
            color: AppColors.gold,
            hasCrown: true,
          ),
          const SizedBox(width: 12),
          // 3rd Place (Bronze)
          _buildPodiumColumn(
            entry: third,
            rank: 3,
            height: 90,
            color: AppColors.bronze,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardEntry entry,
    required int rank,
    required double height,
    required Color color,
    bool hasCrown = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasCrown)
            const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 28)
          else
            const SizedBox(height: 16),
          CircleAvatar(
            radius: rank == 1 ? 26 : 22,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0] : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rank == 1 ? 18 : 15,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
