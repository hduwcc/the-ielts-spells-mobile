import '../models/vocab_card_model.dart';

enum SrsRating {
  again,
  hard,
  good,
  easy,
}

class SrsCalculator {
  static VocabCardModel calculateNextState(VocabCardModel card, SrsRating rating) {
    int nextInterval = 0;
    int nextRepetition = card.repetitionCount;
    SrsStage nextStage = card.srsStage;

    switch (rating) {
      case SrsRating.again:
        nextRepetition = 0;
        nextInterval = 0;
        nextStage = SrsStage.learning;
        break;

      case SrsRating.hard:
        nextRepetition++;
        nextInterval = card.intervalDays == 0 ? 1 : (card.intervalDays * 1.2).round();
        break;

      case SrsRating.good:
        nextRepetition++;
        if (card.repetitionCount == 0) {
          nextInterval = 1;
        } else if (card.repetitionCount == 1) {
          nextInterval = 3;
        } else {
          nextInterval = (card.intervalDays * 2.5).round();
        }
        break;

      case SrsRating.easy:
        nextRepetition += 2;
        if (card.intervalDays == 0) {
          nextInterval = 4;
        } else {
          nextInterval = (card.intervalDays * 2.5 * 1.3).round();
        }
        break;
    }

    // Determine Stage
    if (nextInterval == 0) {
      nextStage = SrsStage.learning;
    } else if (nextInterval < 7) {
      nextStage = SrsStage.learning;
    } else if (nextInterval < 21) {
      nextStage = SrsStage.reviewing;
    } else {
      nextStage = SrsStage.mastered;
    }

    final nextReviewDate = DateTime.now().add(Duration(days: nextInterval));

    return card.copyWith(
      srsStage: nextStage,
      repetitionCount: nextRepetition,
      intervalDays: nextInterval,
      nextReviewAt: nextReviewDate,
    );
  }
}
