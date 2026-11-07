import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../domain/srs_calculator.dart';
import '../models/vocab_card_model.dart';
import 'flashcard_3d_flip_widget.dart';
import 'smart_filter_bar.dart';

class SrsDeckScreen extends StatefulWidget {
  const SrsDeckScreen({super.key});

  @override
  State<SrsDeckScreen> createState() => _SrsDeckScreenState();
}

class _SrsDeckScreenState extends State<SrsDeckScreen> {
  List<Map<String, dynamic>> _decks = [];
  Map<String, dynamic>? _selectedDeck;
  List<VocabCardModel> _allCards = [];
  List<VocabCardModel> _filteredCards = [];
  int _currentIndex = 0;
  bool _isCardFlipped = false;
  int _sessionReviewedCount = 0;
  bool _isLoading = true;

  // Filter States
  SrsStage? _selectedStage;
  String? _selectedBand;
  bool _filterErrorOnly = false;

  @override
  void initState() {
    super.initState();
    _loadDecksAndCards();
  }

  Future<void> _loadDecksAndCards() async {
    setState(() => _isLoading = true);
    final decks = await ApiClient.getCuratedDecks();
    _decks = decks;
    if (_decks.isNotEmpty) {
      _selectedDeck = _decks.first;
    }

    // Load initial study session cards for selected deck
    await _loadDeckSessionCards(_selectedDeck?['id'] ?? 'deck_acad_01');
  }

  Future<void> _loadDeckSessionCards(String deckId) async {
    final sessionData = await ApiClient.getCuratedDeckSession(deckId);
    final rawItems = sessionData['items'] as List<dynamic>? ?? [];

    setState(() {
      _allCards = rawItems
          .map((j) => VocabCardModel.fromJson(Map<String, dynamic>.from(j as Map)))
          .toList();
      _isLoading = false;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredCards = _allCards.where((c) {
        if (_selectedStage != null && c.srsStage != _selectedStage) return false;
        if (_selectedBand != null && c.targetBand != _selectedBand) return false;
        if (_filterErrorOnly && c.errorSource == ErrorSource.none) return false;
        return true;
      }).toList();
      _currentIndex = 0;
      _isCardFlipped = false;
    });
  }

  void _onRatingSelected(SrsRating rating) {
    if (_filteredCards.isEmpty) return;

    final currentCard = _filteredCards[_currentIndex];
    final updatedCard = SrsCalculator.calculateNextState(currentCard, rating);

    HapticService.selection();
    AudioService.playCardFlip();

    // Async sync to web backend
    ApiClient.updateCuratedProgress(
      deckId: _selectedDeck?['id'] ?? 'deck_acad_01',
      itemId: currentCard.id,
      masteryStatus: rating == SrsRating.easy ? 'MASTERED' : 'REVIEWING',
    );

    setState(() {
      _sessionReviewedCount++;
      final indexInAll = _allCards.indexWhere((c) => c.id == currentCard.id);
      if (indexInAll != -1) {
        _allCards[indexInAll] = updatedCard;
      }

      if (_currentIndex < _filteredCards.length - 1) {
        _currentIndex++;
        _isCardFlipped = false;
      } else {
        _showSessionSummary();
      }
    });
  }

  void _showSessionSummary() {
    AudioService.playLevelUp();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 8),
            Text('Hoàn thành lượt học!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bộ từ: ${_selectedDeck?['name'] ?? 'Tuyển chọn'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('• Đã ôn tập: $_sessionReviewedCount từ vựng'),
            const Text('• Điểm thưởng XP: +25 XP'),
            const Text('• Tiến độ đã đồng bộ lên máy chủ trung tâm!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Về Trang Chủ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadDeckSessionCards(_selectedDeck?['id'] ?? 'deck_acad_01');
            },
            child: const Text('Luyện Thêm Lượt Nữa'),
          ),
        ],
      ),
    );
  }

  void _showDeckPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.collections_bookmark_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Bộ từ vựng từ Web The IELTS Spells',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...(_decks.map((deck) {
                final isSelected = deck['id'] == _selectedDeck?['id'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySubtle : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderCard,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      deck['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${deck['totalWords'] ?? 0} từ • Đã thuộc: ${deck['masteredWords'] ?? 0} từ',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedDeck = deck;
                        _loadDeckSessionCards(deck['id']);
                      });
                    },
                  ),
                );
              })),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCards = _filteredCards.isNotEmpty;
    final currentCard = hasCards ? _filteredCards[_currentIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showDeckPickerSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _selectedDeck?['name'] ?? 'Sổ từ Thông minh (SRS)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Chọn bộ từ khác',
            onPressed: _showDeckPickerSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: Column(
                children: [
                  SmartFilterBar(
                    selectedStage: _selectedStage,
                    selectedBand: _selectedBand,
                    filterErrorOnly: _filterErrorOnly,
                    onStageChanged: (stage) {
                      setState(() => _selectedStage = stage);
                      _applyFilters();
                    },
                    onBandChanged: (band) {
                      setState(() => _selectedBand = band);
                      _applyFilters();
                    },
                    onErrorFilterToggled: (val) {
                      setState(() => _filterErrorOnly = val);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 8),

                  // Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hasCards ? 'Thẻ ${_currentIndex + 1}/${_filteredCards.length}' : '0 thẻ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Đã ôn: $_sessionReviewedCount từ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Flip Card Area
                  Expanded(
                    child: Center(
                      child: hasCards
                          ? Flashcard3DFlipWidget(
                              card: currentCard!,
                              isFlipped: _isCardFlipped,
                              onFlip: () {
                                HapticService.selection();
                                setState(() {
                                  _isCardFlipped = !_isCardFlipped;
                                });
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.done_all_rounded, size: 64, color: AppColors.success),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Không còn thẻ cần ôn trong bộ này!',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _showDeckPickerSheet,
                                    child: const Text('Chọn bộ từ vựng khác'),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // 4-level SRS Rating Buttons (when flipped)
                  if (hasCards && _isCardFlipped) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          _buildRatingButton(
                            label: 'Quên',
                            interval: 'Lặp lại',
                            color: AppColors.error,
                            rating: SrsRating.again,
                          ),
                          const SizedBox(width: 8),
                          _buildRatingButton(
                            label: 'Khó',
                            interval: '1 ngày',
                            color: AppColors.warning,
                            rating: SrsRating.hard,
                          ),
                          const SizedBox(width: 8),
                          _buildRatingButton(
                            label: 'Nhớ',
                            interval: '3 ngày',
                            color: AppColors.success,
                            rating: SrsRating.good,
                          ),
                          const SizedBox(width: 8),
                          _buildRatingButton(
                            label: 'Thuộc',
                            interval: '7 ngày',
                            color: AppColors.freezeBlue,
                            rating: SrsRating.easy,
                          ),
                        ],
                      ),
                    ),
                  ] else if (hasCards) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticService.selection();
                          setState(() {
                            _isCardFlipped = true;
                          });
                        },
                        icon: const Icon(Icons.flip_rounded),
                        label: const Text('Xem đáp án mặt sau'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }

  Widget _buildRatingButton({
    required String label,
    required String interval,
    required Color color,
    required SrsRating rating,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onRatingSelected(rating),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                interval,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
