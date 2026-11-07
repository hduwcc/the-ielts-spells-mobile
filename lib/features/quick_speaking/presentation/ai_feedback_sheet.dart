import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/speaking_models.dart';

class AiFeedbackSheet extends StatelessWidget {
  final SpeakingAiFeedback feedback;
  final VoidCallback onClose;

  const AiFeedbackSheet({
    super.key,
    required this.feedback,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đánh giá AI (Gemini 2.5 Flash)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Scores Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScorePill('TỔNG ĐIỂM', feedback.overallScore, AppColors.primaryLight),
                _buildScorePill('PHÁT ÂM', feedback.pronunciationScore, AppColors.gold),
                _buildScorePill('TRÔI CHẢY', feedback.fluencyScore, AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                // Transcript Section
                const Text(
                  'Bản gỡ băng bài nói của bạn:',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '"${feedback.transcript}"',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Mispronounced words
                if (feedback.mispronouncedWords.isNotEmpty) ...[
                  const Text(
                    'Từ cần sửa phát âm:',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...feedback.mispronouncedWords.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.volume_up_outlined, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.word,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.ipa,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.tip,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                ],
                // AI Feedback Summary
                const Text(
                  'Nhận xét của AI:',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  feedback.shortFeedbackVi,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 18),
                // Upgraded Sample Band 7.5+
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.stars_rounded, color: AppColors.gold, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Gợi ý nâng cấp Band 7.5+:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feedback.upgradedSampleBand75,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              child: const Text('Nhận +30 XP & Hoàn tất'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePill(String title, double score, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
