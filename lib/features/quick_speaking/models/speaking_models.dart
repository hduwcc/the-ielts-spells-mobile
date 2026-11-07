class SpeakingPrompt {
  final String id;
  final String questionPrompt;
  final String topicCategory;
  final int targetTimeSeconds;
  final List<String> suggestedKeywords;

  SpeakingPrompt({
    required this.id,
    required this.questionPrompt,
    required this.topicCategory,
    required this.targetTimeSeconds,
    required this.suggestedKeywords,
  });

  factory SpeakingPrompt.fromJson(Map<String, dynamic> json) {
    return SpeakingPrompt(
      id: json['id'] ?? '',
      questionPrompt: json['questionPrompt'] ?? '',
      topicCategory: json['topicCategory'] ?? 'Part 1',
      targetTimeSeconds: json['targetTimeSeconds'] ?? 45,
      suggestedKeywords: List<String>.from(json['suggestedKeywords'] ?? []),
    );
  }
}

class MispronouncedWord {
  final String word;
  final String ipa;
  final String tip;

  MispronouncedWord({
    required this.word,
    required this.ipa,
    required this.tip,
  });

  factory MispronouncedWord.fromJson(Map<String, dynamic> json) {
    return MispronouncedWord(
      word: json['word'] ?? '',
      ipa: json['ipa'] ?? '',
      tip: json['tip'] ?? '',
    );
  }
}

class SpeakingAiFeedback {
  final double pronunciationScore;
  final double fluencyScore;
  final double overallScore;
  final String transcript;
  final List<MispronouncedWord> mispronouncedWords;
  final int fillerWordsCount;
  final String shortFeedbackVi;
  final String upgradedSampleBand75;

  SpeakingAiFeedback({
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.overallScore,
    required this.transcript,
    required this.mispronouncedWords,
    required this.fillerWordsCount,
    required this.shortFeedbackVi,
    required this.upgradedSampleBand75,
  });

  factory SpeakingAiFeedback.fromJson(Map<String, dynamic> json) {
    final misList = (json['mispronouncedWords'] as List? ?? [])
        .map((m) => MispronouncedWord.fromJson(m as Map<String, dynamic>))
        .toList();

    return SpeakingAiFeedback(
      pronunciationScore: (json['pronunciationScore'] as num? ?? 6.0).toDouble(),
      fluencyScore: (json['fluencyScore'] as num? ?? 6.0).toDouble(),
      overallScore: (json['overallScore'] as num? ?? 6.0).toDouble(),
      transcript: json['transcript'] ?? '',
      mispronouncedWords: misList,
      fillerWordsCount: json['fillerWordsCount'] ?? 0,
      shortFeedbackVi: json['shortFeedbackVi'] ?? '',
      upgradedSampleBand75: json['upgradedSampleBand75'] ?? '',
    );
  }
}
