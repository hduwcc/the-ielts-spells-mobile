import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../data/mini_games_dataset.dart';
import '../models/game_models.dart';
import 'game_result_dialog.dart';

class GrammarDetectiveScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  const GrammarDetectiveScreen({super.key, this.difficulty = GameDifficulty.medium});

  @override
  State<GrammarDetectiveScreen> createState() => _GrammarDetectiveScreenState();
}

class _GrammarDetectiveScreenState extends State<GrammarDetectiveScreen> {
  static const int _secondsPerQuestion = 10;
  int _secondsRemaining = _secondsPerQuestion;
  Timer? _countdownTimer;

  late final List<GrammarDetectiveItem> _items;

  int _currentIndex = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;

  bool _isAnswered = false;
  int? _selectedTokenIndex;
  bool _isCorrectChoice = false;

  @override
  void initState() {
    super.initState();
    _items = MiniGamesDataset.getGrammarItems(widget.difficulty)
        .map((g) => GrammarDetectiveItem.fromJson(g))
        .toList();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startQuestionTimer() {
    _secondsRemaining = _secondsPerQuestion;
    _isAnswered = false;
    _selectedTokenIndex = null;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    _countdownTimer?.cancel();
    if (_isAnswered) return;

    AudioService.playError();
    HapticService.error();

    setState(() {
      _isAnswered = true;
      _combo = 0;
      _isCorrectChoice = false;
    });
  }

  void _onTokenSelected(int index) {
    if (_isAnswered) return;

    _countdownTimer?.cancel();
    final currentItem = _items[_currentIndex];
    final bool isCorrect = index == currentItem.errorIndex;

    setState(() {
      _isAnswered = true;
      _selectedTokenIndex = index;
      _isCorrectChoice = isCorrect;
    });

    if (isCorrect) {
      final newCombo = _combo + 1;
      final newMaxCombo = newCombo > _maxCombo ? newCombo : _maxCombo;
      final int addedScore = 15 + (_secondsRemaining * 2);

      AudioService.playComboHit(newCombo);
      HapticService.comboHit(newCombo);

      setState(() {
        _combo = newCombo;
        _maxCombo = newMaxCombo;
        _score += addedScore;
      });
    } else {
      AudioService.playError();
      HapticService.error();

      setState(() {
        _combo = 0;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _items.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startQuestionTimer();
    } else {
      _endGame();
    }
  }

  Future<void> _endGame() async {
    _countdownTimer?.cancel();
    final result = await ApiClient.submitGameResult(
      gameType: 'GRAMMAR_DETECTIVE',
      score: _score,
      maxCombo: _maxCombo,
      timeSpentSeconds: 40,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        gameTitle: 'Grammar Detective',
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
          _startQuestionTimer();
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
        title: const Text('Grammar Detective'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Câu ${_currentIndex + 1}/${_items.length}',
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
              // Timer & Score header
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  // Circular Countdown Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: _secondsRemaining / _secondsPerQuestion,
                          strokeWidth: 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _secondsRemaining <= 3 ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '$_secondsRemaining',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: _secondsRemaining <= 3 ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentItem.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chạm trực tiếp vào từ bị lỗi ngữ pháp trong câu sau:',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              // Sentence Action Chips
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: List.generate(currentItem.tokens.length, (index) {
                  final token = currentItem.tokens[index];
                  final isErrorToken = index == currentItem.errorIndex;
                  final isSelected = index == _selectedTokenIndex;

                  Color chipColor = AppColors.surface;
                  Color borderColor = AppColors.border;
                  Color textColor = AppColors.textPrimary;

                  if (_isAnswered) {
                    if (isErrorToken) {
                      chipColor = AppColors.error.withOpacity(0.2);
                      borderColor = AppColors.error;
                      textColor = AppColors.error;
                    } else if (isSelected && !isErrorToken) {
                      chipColor = AppColors.border;
                      borderColor = AppColors.borderLight;
                    }
                  }

                  return GestureDetector(
                    onTap: () => _onTokenSelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Text(
                        token,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              // Instant Explanation Drawer
              if (_isAnswered) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrectChoice
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isCorrectChoice ? AppColors.success : AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isCorrectChoice ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: _isCorrectChoice ? AppColors.success : AppColors.error,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isCorrectChoice ? 'Chính xác! (+15 XP)' : 'Chưa đúng!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isCorrectChoice ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sửa đúng: "${currentItem.correctedToken.isEmpty ? '[Bỏ từ này]' : currentItem.correctedToken}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentItem.explanationVi,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(_currentIndex < _items.length - 1 ? 'Câu tiếp theo' : 'Xem kết quả'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
