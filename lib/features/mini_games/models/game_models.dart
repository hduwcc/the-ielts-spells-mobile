class CollocationPair {
  final String left;
  final String right;

  CollocationPair({required this.left, required this.right});

  factory CollocationPair.fromJson(Map<String, String> json) {
    return CollocationPair(
      left: json['left'] ?? '',
      right: json['right'] ?? '',
    );
  }
}

class GrammarDetectiveItem {
  final String id;
  final List<String> tokens;
  final int errorIndex;
  final String correctedToken;
  final String category;
  final String explanationVi;

  GrammarDetectiveItem({
    required this.id,
    required this.tokens,
    required this.errorIndex,
    required this.correctedToken,
    required this.category,
    required this.explanationVi,
  });

  factory GrammarDetectiveItem.fromJson(Map<String, dynamic> json) {
    return GrammarDetectiveItem(
      id: json['id'] ?? '',
      tokens: List<String>.from(json['tokens'] ?? []),
      errorIndex: json['errorIndex'] ?? 0,
      correctedToken: json['correctedToken'] ?? '',
      category: json['category'] ?? '',
      explanationVi: json['explanationVi'] ?? '',
    );
  }
}

class SpeedVocabItem {
  final String id;
  final String word;
  final String pos;
  final String phonetic;
  final String correctMeaning;
  final List<String> options;

  SpeedVocabItem({
    required this.id,
    required this.word,
    required this.pos,
    required this.phonetic,
    required this.correctMeaning,
    required this.options,
  });

  factory SpeedVocabItem.fromJson(Map<String, dynamic> json) {
    return SpeedVocabItem(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      pos: json['pos'] ?? '',
      phonetic: json['phonetic'] ?? '',
      correctMeaning: json['correctMeaning'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }
}
