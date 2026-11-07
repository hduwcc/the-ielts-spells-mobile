import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/vocab_card_model.dart';

class Flashcard3DFlipWidget extends StatefulWidget {
  final VocabCardModel card;
  final bool isFlipped;
  final VoidCallback onFlip;

  const Flashcard3DFlipWidget({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
  });

  @override
  State<Flashcard3DFlipWidget> createState() => _Flashcard3DFlipWidgetState();
}

class _Flashcard3DFlipWidgetState extends State<Flashcard3DFlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );

    if (widget.isFlipped) {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant Flashcard3DFlipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        widget.onFlip();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double angle = _animation.value * pi;
          final bool isUnder = angle > (pi / 2);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015) // 3D perspective
              ..rotateY(angle),
            child: isUnder
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBackCard(),
                  )
                : _buildFrontCard(),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      height: 380,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBandBadge(widget.card.targetBand),
              _buildErrorSourceBadge(widget.card.errorSource),
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Text(
                  widget.card.word,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.card.phonetic} • (${widget.card.pos})',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_outlined, size: 16, color: AppColors.textTertiary),
                SizedBox(width: 6),
                Text(
                  'Chạm để lật mặt sau',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: double.infinity,
      height: 380,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.card.word,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
              _buildSrsStageBadge(widget.card.srsStage),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.card.meaningVi,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ngữ cảnh IELTS Band 7.0+:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.card.exampleEn,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.card.exampleVi,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (widget.card.synonyms.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Từ đồng nghĩa:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.card.synonyms.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
            ),
          ],
          const Spacer(),
          const Center(
            child: Text(
              'Đánh giá mức độ nhớ của bạn ở bên dưới:',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandBadge(String band) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
      ),
      child: Text(
        'Band $band+',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget _buildErrorSourceBadge(ErrorSource source) {
    if (source == ErrorSource.none) return const SizedBox();

    String label = 'Lỗi từ Web';
    Color color = AppColors.flameOrange;
    if (source == ErrorSource.webReading) {
      label = 'Lỗi Reading';
    } else if (source == ErrorSource.webWriting) {
      label = 'Lỗi Writing AI';
      color = AppColors.primaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_problem_rounded, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSrsStageBadge(SrsStage stage) {
    String label = 'Mới học';
    Color color = AppColors.textTertiary;

    switch (stage) {
      case SrsStage.newWord:
        label = 'MỚI HỌC';
        color = AppColors.textSecondary;
        break;
      case SrsStage.learning:
        label = 'ĐANG ÔN';
        color = AppColors.flameOrange;
        break;
      case SrsStage.reviewing:
        label = 'GẦN NHỚ';
        color = AppColors.freezeBlue;
        break;
      case SrsStage.mastered:
        label = 'ĐÃ THUỘC';
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
