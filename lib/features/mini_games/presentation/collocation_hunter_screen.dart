import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../data/mini_games_dataset.dart';
import '../models/game_models.dart';
import 'game_result_dialog.dart';

class CollocationHunterScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  const CollocationHunterScreen({super.key, this.difficulty = GameDifficulty.medium});

  @override
  State<CollocationHunterScreen> createState() => _CollocationHunterScreenState();
}

class _CollocationHunterScreenState extends State<CollocationHunterScreen> {
  static const int _gameDurationSeconds = 30;
  int _secondsRemaining = _gameDurationSeconds;
  Timer? _gameTimer;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;

  late final List<CollocationPair> _allPairs;

  List<_CollocationCard> _activeCards = [];
  _CollocationCard? _selectedCard;
  int _pairRoundIndex = 0;

  @override
  void initState() {
    super.initState();
    _allPairs = MiniGamesDataset.getCollocations(widget.difficulty)
        .map((p) => CollocationPair.fromJson(p))
        .toList();
    _loadNewCardSet();
    _startTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _loadNewCardSet() {
    final List<_CollocationCard> cards = [];
    const int pairsPerRound = 4;
    final int startIdx = (_pairRoundIndex * pairsPerRound) % _allPairs.length;

    for (int i = 0; i < pairsPerRound; i++) {
      final pair = _allPairs[(startIdx + i) % _allPairs.length];
      cards.add(_CollocationCard(
        id: 'L_${startIdx + i}',
        text: pair.left,
        isLeft: true,
        pairId: 'P_${startIdx + i}',
      ));
      cards.add(_CollocationCard(
        id: 'R_${startIdx + i}',
        text: pair.right,
        isLeft: false,
        pairId: 'P_${startIdx + i}',
      ));
    }
    cards.shuffle();
    setState(() {
      _activeCards = cards;
      _selectedCard = null;
      _pairRoundIndex++;
    });
  }

  void _onCardTap(_CollocationCard card) {
    if (card.isMatched || _secondsRemaining <= 0) return;

    HapticService.selection();

    if (_selectedCard == null) {
      setState(() {
        _selectedCard = card;
      });
      return;
    }

    if (_selectedCard!.id == card.id) {
      // Tap same card again to unselect
      setState(() {
        _selectedCard = null;
      });
      return;
    }

    // Check if one is left and one is right with matching pairId
    final bool isMatch = (_selectedCard!.pairId == card.pairId) &&
        (_selectedCard!.isLeft != card.isLeft);

    if (isMatch) {
      // Correct Match!
      final newCombo = _combo + 1;
      final newMaxCombo = newCombo > _maxCombo ? newCombo : _maxCombo;
      final double multiplier = newCombo >= 10
          ? 3.0
          : newCombo >= 6
              ? 2.0
              : newCombo >= 3
                  ? 1.5
                  : 1.0;
      final int addedScore = (10 * multiplier).toInt();

      AudioService.playComboHit(newCombo);
      HapticService.comboHit(newCombo);

      setState(() {
        card.isMatched = true;
        _selectedCard!.isMatched = true;
        _selectedCard = null;
        _combo = newCombo;
        _maxCombo = newMaxCombo;
        _score += addedScore;
      });

      // Check if all cards in this round matched
      if (_activeCards.every((c) => c.isMatched)) {
        HapticService.heavy();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _secondsRemaining > 0) {
            _loadNewCardSet();
          }
        });
      }
    } else {
      // Mismatched
      AudioService.playError();
      HapticService.error();

      setState(() {
        _combo = 0;
        _selectedCard = null;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa chính xác! Thử lại cụm khác nhé.'),
          duration: Duration(milliseconds: 600),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    final result = await ApiClient.submitGameResult(
      gameType: 'COLLOCATION_HUNTER',
      score: _score,
      maxCombo: _maxCombo,
      timeSpentSeconds: _gameDurationSeconds,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        gameTitle: 'Collocation Hunter',
        score: _score,
        maxCombo: _maxCombo,
        xpEarned: result['xpEarned'] ?? 35,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _secondsRemaining = _gameDurationSeconds;
            _score = 0;
            _combo = 0;
            _maxCombo = 0;
            _pairRoundIndex = 0;
          });
          _loadNewCardSet();
          _startTimer();
        },
        onExit: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // close screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFever = _combo >= 10;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Collocation Hunter'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsRemaining <= 5
                  ? AppColors.error.withOpacity(0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _secondsRemaining <= 5 ? AppColors.error : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: _secondsRemaining <= 5 ? AppColors.error : AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_secondsRemaining}s',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining <= 5 ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: isFever
            ? BoxDecoration(
                border: Border.all(color: AppColors.feverGlow, width: 3),
              )
            : null,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Score & Combo Banner
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isFever ? AppColors.feverGlow : AppColors.flameOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isFever ? Colors.white : AppColors.flameOrange,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          isFever ? '🔥 FEVER x3.0 ($_combo)' : '🔥 COMBO x${(_combo >= 6 ? '2.0' : '1.5')} ($_combo)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chạm 1 nửa cụm từ bên trái và nối với 1 nửa bên phải thích hợp:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                // Card Grid
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _activeCards.length,
                    itemBuilder: (context, index) {
                      final card = _activeCards[index];
                      final isSelected = _selectedCard?.id == card.id;

                      if (card.isMatched) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border.withOpacity(0.4)),
                          ),
                          child: const Center(
                            child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () => _onCardTap(card),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryLight : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              card.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollocationCard {
  final String id;
  final String text;
  final bool isLeft;
  final String pairId;
  bool isMatched;

  _CollocationCard({
    required this.id,
    required this.text,
    required this.isLeft,
    required this.pairId,
  }) : isMatched = false;
}
