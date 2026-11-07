import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/mock_data.dart';
import '../models/speaking_models.dart';
import 'ai_feedback_sheet.dart';
import 'live_waveform_painter.dart';

class QuickSpeakingScreen extends StatefulWidget {
  const QuickSpeakingScreen({super.key});

  @override
  State<QuickSpeakingScreen> createState() => _QuickSpeakingScreenState();
}

class _QuickSpeakingScreenState extends State<QuickSpeakingScreen> {
  final SpeakingPrompt _prompt =
      SpeakingPrompt.fromJson(MockData.quickSpeakingDailyPrompt);

  bool _isRecording = false;
  bool _isEvaluating = false;
  int _secondsRecorded = 0;
  Timer? _recordTimer;

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecordingAndEvaluate();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    HapticService.heavy();
    AudioService.playComboHit(1);

    setState(() {
      _isRecording = true;
      _secondsRecorded = 0;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRecorded < _prompt.targetTimeSeconds) {
        setState(() {
          _secondsRecorded++;
        });
      } else {
        _stopRecordingAndEvaluate();
      }
    });
  }

  Future<void> _stopRecordingAndEvaluate() async {
    _recordTimer?.cancel();
    HapticService.medium();

    if (_secondsRecorded < 3) {
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bài nói quá ngắn! Vui lòng nói tối thiểu 3 giây.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isRecording = false;
      _isEvaluating = true;
    });

    try {
      final response = await ApiClient.evaluateQuickSpeaking(
        questionPrompt: _prompt.questionPrompt,
        audioPath: 'mock_audio.m4a',
        durationSeconds: _secondsRecorded,
      );

      final feedback = SpeakingAiFeedback.fromJson(response);

      if (!mounted) return;
      setState(() {
        _isEvaluating = false;
      });

      AudioService.playLevelUp();
      HapticService.heavy();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AiFeedbackSheet(
          feedback: feedback,
          onClose: () {
            Navigator.pop(context); // close sheet
            Navigator.pop(context); // close speaking screen back to home
          },
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isEvaluating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể kết nối dịch vụ AI. Vui lòng thử lại!'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Luyện Speaking Phản Xạ AI'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _prompt.topicCategory,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Daily Question Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Câu hỏi hôm nay (Part 1):',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _prompt.questionPrompt,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Từ khóa gợi ý Band 7.0+:',
                      style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _prompt.suggestedKeywords.map((kw) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                          ),
                          child: Text(
                            kw,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Waveform Display
              Center(
                child: LiveWaveformWidget(isRecording: _isRecording),
              ),
              const SizedBox(height: 16),
              // Timer & Status Text
              Center(
                child: Column(
                  children: [
                    Text(
                      _isEvaluating
                          ? 'AI đang phân tích phát âm & độ trôi chảy...'
                          : _isRecording
                              ? '00:${_secondsRecorded.toString().padLeft(2, '0')} / 00:${_prompt.targetTimeSeconds}'
                              : 'Chạm micro để bắt đầu nói (${_prompt.targetTimeSeconds}s)',
                      style: TextStyle(
                        fontSize: _isRecording ? 20 : 14,
                        fontWeight: _isRecording ? FontWeight.bold : FontWeight.w500,
                        color: _isRecording ? AppColors.primaryLight : AppColors.textSecondary,
                      ),
                    ),
                    if (_isRecording)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Chạm lại để hoàn tất và gửi cho AI',
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Mic Button
              Center(
                child: _isEvaluating
                    ? const SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : GestureDetector(
                        onTap: _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? AppColors.primaryDark : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(_isRecording ? 0.6 : 0.3),
                                blurRadius: _isRecording ? 24 : 12,
                                spreadRadius: _isRecording ? 6 : 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
