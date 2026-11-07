import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../data/mini_games_dataset.dart';
import '../models/game_models.dart';
import 'game_result_dialog.dart';

class SpeedVocabScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  const SpeedVocabScreen({super.key, this.difficulty = GameDifficulty.medium});

  @override
  State<SpeedVocabScreen> createState() => _SpeedVocabScreenState();
}

class _SpeedVocabScreenState extends State<SpeedVocabScreen>
    with SingleTickerProviderStateMixin {
  static const int _secondsPerWord = 5;
  late AnimationController _timerAnimController;

  late final List<SpeedVocabItem> _items;

  int _currentIndex = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;

  DateTime? _questionStartTime;
  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _items = MiniGamesDataset.getSpeedVocabItems(widget.difficulty)
        .map((s) => SpeedVocabItem.fromJson(s))
        .toList();
    _timerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _secondsPerWord),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _handleTimeOut();
        }
      });

    _startQuestion();
  }

  @override
  void dispose() {
    _timerAnimController.dispose();
    super.dispose();
  }

  void _startQuestion() {
    _isAnswered = false;
    _selectedOption = null;
    _questionStartTime = DateTime.now();
    _timerAnimController.forward(from: 0.0);
  }

  void _handleTimeOut() {
    if (_isAnswered) return;

    AudioService.playError();
    HapticService.error();

    setState(() {
      _isAnswered = true;
      _combo = 0;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _nextWord();
    });
  }

  void _onOptionSelected(String option) {
    if (_isAnswered) return;

    _timerAnimController.stop();
    final elapsedMs = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _items[_currentIndex];
    final bool isCorrect = option == currentItem.correctMeaning;

    setState(() {
      _isAnswered = true;
      _selectedOption = option;
    });

    if (isCorrect) {
      final newCombo = _combo + 1;
      final newMaxCombo = newCombo > _maxCombo ? newCombo : _maxCombo;
      final bool isSpeedBonus = elapsedMs <= 1500;
      final int addedScore = 10 + (isSpeedBonus ? 5 : 0);

      AudioService.playComboHit(newCombo);
      HapticService.comboHit(newCombo);

      setState(() {
        _combo = newCombo;
        _maxCombo = newMaxCombo;
        _score += addedScore;
      });

      if (isSpeedBonus) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ TỐC ĐỘ CHỚP NHOÁNG! (+5 XP Speed Bonus)'),
            duration: Duration(milliseconds: 600),
            backgroundColor: AppColors.gold,
          ),
        );
      }
    } else {
      AudioService.playError();
      HapticService.error();

      setState(() {
        _combo = 0;
      });
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _nextWord();
    });
  }

  void _nextWord() {
    if (_currentIndex < _items.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startQuestion();
    } else {
      _endGame();
    }
  }

  Future<void> _endGame() async {
    _timerAnimController.stop();
    final result = await ApiClient.submitGameResult(
      gameType: 'SPEED_VOCAB',
      score: _score,
      maxCombo: _maxCombo,
      timeSpentSeconds: 25,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        gameTitle: 'Speed Vocab',
        score: _score,
        maxCombo: _maxCombo,
        xpEarned: result['xpEarned'] ?? 30,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _currentIndex = 0;
            _score = 0;
            _combo = 0;
            _maxCombo = 0;
          });
          _startQuestion();
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _items[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Speed Vocab'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Từ ${_currentIndex + 1}/${_items.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Score & Fast Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ĐIỂM SỐ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  if (_combo > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.flameOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.flameOrange),
                      ),
                      child: Text(
                        '🔥 Combo x$_combo',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Linear Timer Bar
              AnimatedBuilder(
                animation: _timerAnimController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 1.0 - _timerAnimController.value,
                      minHeight: 6,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timerAnimController.value > 0.7 ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),
              // Main Vocab Card
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentItem.word,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currentItem.phonetic} • (${currentItem.pos})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // 4 Choice Options
              ...currentItem.options.map((option) {
                final isCorrectOption = option == currentItem.correctMeaning;
                final isSelected = option == _selectedOption;

                Color btnBg = AppColors.surface;
                Color borderClr = AppColors.border;

                if (_isAnswered) {
                  if (isCorrectOption) {
                    btnBg = AppColors.success.withOpacity(0.2);
                    borderClr = AppColors.success;
                  } else if (isSelected && !isCorrectOption) {
                    btnBg = AppColors.error.withOpacity(0.2);
                    borderClr = AppColors.error;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () => _onOptionSelected(option),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: btnBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderClr, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: (_isAnswered && isCorrectOption)
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_isAnswered && isCorrectOption)
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                          if (_isAnswered && isSelected && !isCorrectOption)
                            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
