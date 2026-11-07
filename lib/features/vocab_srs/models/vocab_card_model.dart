enum SrsStage {
  newWord,
  learning,
  reviewing,
  mastered,
}

enum ErrorSource {
  none,
  webReading,
  webWriting,
  miniGame,
}

class VocabCardModel {
  final String id;
  final String word;
  final String pos;
  final String phonetic;
  final String meaningVi;
  final String exampleEn;
  final String exampleVi;
  final SrsStage srsStage;
  final String targetBand;
  final ErrorSource errorSource;
  final List<String> synonyms;
  final int repetitionCount;
  final int intervalDays;
  final DateTime nextReviewAt;

  VocabCardModel({
    required this.id,
    required this.word,
    required this.pos,
    required this.phonetic,
    required this.meaningVi,
    required this.exampleEn,
    required this.exampleVi,
    required this.srsStage,
    required this.targetBand,
    required this.errorSource,
    required this.synonyms,
    required this.repetitionCount,
    required this.intervalDays,
    required this.nextReviewAt,
  });

  factory VocabCardModel.fromJson(Map<String, dynamic> json) {
    SrsStage stage = SrsStage.newWord;
    final stageStr = (json['srsStage'] as String? ?? 'NEW').toUpperCase();
    if (stageStr == 'LEARNING') {
      stage = SrsStage.learning;
    } else if (stageStr == 'REVIEWING') {
      stage = SrsStage.reviewing;
    } else if (stageStr == 'MASTERED') {
      stage = SrsStage.mastered;
    }

    ErrorSource source = ErrorSource.none;
    final sourceStr = (json['errorSource'] as String? ?? 'NONE').toUpperCase();
    if (sourceStr == 'WEB_READING') {
      source = ErrorSource.webReading;
    } else if (sourceStr == 'WEB_WRITING') {
      source = ErrorSource.webWriting;
    } else if (sourceStr == 'MINI_GAME') {
      source = ErrorSource.miniGame;
    }

    return VocabCardModel(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      pos: json['pos'] ?? '',
      phonetic: json['phonetic'] ?? '',
      meaningVi: json['meaningVi'] ?? '',
      exampleEn: json['exampleEn'] ?? '',
      exampleVi: json['exampleVi'] ?? '',
      srsStage: stage,
      targetBand: json['targetBand'] ?? '6.5',
      errorSource: source,
      synonyms: List<String>.from(json['synonyms'] ?? []),
      repetitionCount: json['repetitionCount'] ?? 0,
      intervalDays: json['intervalDays'] ?? 0,
      nextReviewAt: DateTime.tryParse(json['nextReviewAt'] ?? '') ?? DateTime.now(),
    );
  }

  VocabCardModel copyWith({
    SrsStage? srsStage,
    int? repetitionCount,
    int? intervalDays,
    DateTime? nextReviewAt,
  }) {
    return VocabCardModel(
      id: id,
      word: word,
      pos: pos,
      phonetic: phonetic,
      meaningVi: meaningVi,
      exampleEn: exampleEn,
      exampleVi: exampleVi,
      srsStage: srsStage ?? this.srsStage,
      targetBand: targetBand,
      errorSource: errorSource,
      synonyms: synonyms,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }
}
