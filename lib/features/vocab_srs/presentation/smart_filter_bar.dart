import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/vocab_card_model.dart';

class SmartFilterBar extends StatelessWidget {
  final SrsStage? selectedStage;
  final String? selectedBand;
  final bool filterErrorOnly;
  final ValueChanged<SrsStage?> onStageChanged;
  final ValueChanged<String?> onBandChanged;
  final ValueChanged<bool> onErrorFilterToggled;

  const SmartFilterBar({
    super.key,
    required this.selectedStage,
    required this.selectedBand,
    required this.filterErrorOnly,
    required this.onStageChanged,
    required this.onBandChanged,
    required this.onErrorFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Error From Web Filter Chip
          FilterChip(
            selected: filterErrorOnly,
            avatar: Icon(
              Icons.sync_problem_rounded,
              size: 16,
              color: filterErrorOnly ? Colors.white : AppColors.flameOrange,
            ),
            label: const Text('Lỗi từ Web'),
            selectedColor: AppColors.flameOrange,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: filterErrorOnly ? Colors.white : AppColors.textPrimary,
            ),
            side: BorderSide(
              color: filterErrorOnly ? AppColors.flameOrange : AppColors.border,
            ),
            onSelected: (val) {
              HapticService.selection();
              onErrorFilterToggled(val);
            },
          ),
          const SizedBox(width: 8),
          // Stage Filters
          _buildStageChip(null, 'Tất cả trạng thái'),
          const SizedBox(width: 6),
          _buildStageChip(SrsStage.newWord, 'Mới học'),
          const SizedBox(width: 6),
          _buildStageChip(SrsStage.learning, 'Đang ôn'),
          const SizedBox(width: 6),
          _buildStageChip(SrsStage.reviewing, 'Gần nhớ'),
          const SizedBox(width: 6),
          _buildStageChip(SrsStage.mastered, 'Đã thuộc'),
          const SizedBox(width: 8),
          // Band Filters
          _buildBandChip(null, 'Mọi Band'),
          const SizedBox(width: 6),
          _buildBandChip('6.5', 'Band 6.5'),
          const SizedBox(width: 6),
          _buildBandChip('7.5', 'Band 7.5+'),
        ],
      ),
    );
  }

  Widget _buildStageChip(SrsStage? stage, String label) {
    final isSelected = selectedStage == stage;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      onSelected: (_) {
        HapticService.selection();
        onStageChanged(stage);
      },
    );
  }

  Widget _buildBandChip(String? band, String label) {
    final isSelected = selectedBand == band;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: AppColors.primaryLight,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      side: BorderSide(color: isSelected ? AppColors.primaryLight : AppColors.border),
      onSelected: (_) {
        HapticService.selection();
        onBandChanged(band);
      },
    );
  }
}
