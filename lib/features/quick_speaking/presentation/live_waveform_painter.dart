import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LiveWaveformWidget extends StatefulWidget {
  final bool isRecording;

  const LiveWaveformWidget({super.key, required this.isRecording});

  @override
  State<LiveWaveformWidget> createState() => _LiveWaveformWidgetState();
}

class _LiveWaveformWidgetState extends State<LiveWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _WaveformPainter(
            animationValue: _waveController.value,
            isRecording: widget.isRecording,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double animationValue;
  final bool isRecording;

  _WaveformPainter({required this.animationValue, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isRecording ? AppColors.primary : AppColors.borderLight
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    const int barCount = 28;
    final double spacing = size.width / (barCount + 1);
    final double centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final double x = (i + 1) * spacing;
      double height = 6.0;

      if (isRecording) {
        // Generate pseudo-random organic audio waves based on sine and animation
        final double phase = (i / barCount) * 2 * pi + (animationValue * 2 * pi);
        final double wave = (sin(phase) + cos(phase * 1.5)).abs();
        height = (wave * (size.height * 0.42)).clamp(8.0, size.height * 0.85);
      }

      canvas.drawLine(
        Offset(x, centerY - (height / 2)),
        Offset(x, centerY + (height / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isRecording != isRecording;
  }
}
