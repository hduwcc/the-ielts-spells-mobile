class MockData {
  // 1. App Version & Remote Config
  static Map<String, dynamic> get appVersionConfig => {
        'action': 'UP_TO_DATE', // 'UP_TO_DATE' | 'OPTIONAL_UPDATE' | 'FORCE_UPDATE' | 'MAINTENANCE'
        'currentVersion': '1.0.0',
        'latestVersion': '1.0.0',
        'minSupportedVersion': '1.0.0',
        'storeUrl': 'https://theieltsspells.com/app',
        'isUnderMaintenance': false,
        'maintenanceTitle': 'Hệ thống đang bảo trì',
        'maintenanceMessage': 'The IELTS Spells đang nâng cấp hạ tầng. Vui lòng quay lại sau.',
        'releaseNotes': '• Ra mắt IELTS Spells Mobile Companion\n• Tích hợp bộ 3 Mini-Games phản xạ\n• Sổ từ thông minh Spaced Repetition 4 cấp độ\n• Luyện Speaking 45s cùng AI tức thì',
      };

  // 2. Student Streak & Habit
  static Map<String, dynamic> get studentStreak => {
        'currentStreak': 14,
        'longestStreak': 28,
        'lastCompletedDate': DateTime.now().subtract(const Duration(days: 0)).toIso8601String().split('T')[0],
        'freezeShields': 2,
        'maxFreezeShields': 3,
        'totalXp': 2450,
        'dailyGoalXp': 50,
        'todayXp': 35,
        'isCompletedToday': false,
      };

  // 3. Streak Calendar Monthly History
  static List<Map<String, dynamic>> get streakCalendarHistory {
    final now = DateTime.now();
    final List<Map<String, dynamic>> days = [];
    for (int i = 25; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      // Simulate day 7 as FROZEN
      if (i == 7) {
        days.add({'date': dateStr, 'status': 'FROZEN', 'xp': 0});
      } else if (i % 5 != 0) {
        days.add({'date': dateStr, 'status': 'COMPLETED', 'xp': 45 + (i * 2)});
      }
    }
    return days;
  }

  // 4. Mini-Games: Collocation Hunter
  static List<Map<String, String>> get collocationPairs => [
        {'left': 'pose', 'right': 'a serious threat'},
        {'left': 'deeply', 'right': 'rooted in culture'},
        {'left': 'exert', 'right': 'a profound impact'},
        {'left': 'bridge', 'right': 'the generation gap'},
        {'left': 'foster', 'right': 'creativity and innovation'},
        {'left': 'pave', 'right': 'the way for progress'},
        {'left': 'wreak', 'right': 'havoc on wildlife'},
        {'left': 'shed', 'right': 'light on the problem'},
        {'left': 'yield', 'right': 'promising results'},
        {'left': 'bear', 'right': 'full responsibility'},
        {'left': 'adverse', 'right': 'environmental effects'},
        {'left': 'vital', 'right': 'role in development'},
      ];

  // 5. Mini-Games: Grammar Detective
  static List<Map<String, dynamic>> get grammarDetectiveItems => [
        {
          'id': 'g1',
          'tokens': ['The', 'number', 'of', 'vehicles', 'have', 'surged', 'dramatically', 'recently.'],
          'errorIndex': 4,
          'correctedToken': 'has',
          'category': 'Subject-Verb Agreement',
          'explanationVi': '"The number of + danh từ số nhiều" đi với động từ số ít (has surged), còn "A number of" mới đi với số nhiều.',
        },
        {
          'id': 'g2',
          'tokens': ['Despite', 'of', 'studying', 'hard,', 'she', 'could', 'not', 'pass', 'the', 'test.'],
          'errorIndex': 1,
          'correctedToken': '',
          'category': 'Preposition Error',
          'explanationVi': 'Sau "Despite" không có "of" (Despite + N/V-ing). Chỉ có "In spite of" mới dùng giới từ "of".',
        },
        {
          'id': 'g3',
          'tokens': ['Technology', 'allows', 'people', 'communicating', 'easily', 'across', 'borders.'],
          'errorIndex': 3,
          'correctedToken': 'to communicate',
          'category': 'Verb Pattern',
          'explanationVi': 'Cấu trúc chuẩn là "allow someone TO DO something", không dùng trực tiếp V-ing.',
        },
        {
          'id': 'g4',
          'tokens': ['There', 'are', 'many', 'informations', 'available', 'on', 'the', 'internet.'],
          'errorIndex': 3,
          'correctedToken': 'pieces of information',
          'category': 'Uncountable Noun',
          'explanationVi': '"Information" là danh từ không đếm được, không thêm "s". Cần dùng "pieces of information" hoặc "much information".',
        },
      ];

  // 6. Mini-Games: Speed Vocab
  static List<Map<String, dynamic>> get speedVocabItems => [
        {
          'id': 'sv1',
          'word': 'Procrastinate',
          'pos': 'v',
          'phonetic': '/prəˈkræs.tɪ.neɪt/',
          'correctMeaning': 'Trì hoãn, chần chừ',
          'options': ['Thúc đẩy tiến độ', 'Trì hoãn, chần chừ', 'Hợp tác chặt chẽ', 'Phân chia tài nguyên'],
        },
        {
          'id': 'sv2',
          'word': 'Ubiquitous',
          'pos': 'adj',
          'phonetic': '/juːˈbɪk.wə.təs/',
          'correctMeaning': 'Phổ biến, ở đâu cũng có',
          'options': ['Hiếm gặp, quý giá', 'Tạm thời, ngắn ngủi', 'Phổ biến, ở đâu cũng có', 'Nghiêm khắc, ngặt nghèo'],
        },
        {
          'id': 'sv3',
          'word': 'Mitigate',
          'pos': 'v',
          'phonetic': '/ˈmɪt.ɪ.ɡeɪt/',
          'correctMeaning': 'Làm giảm bớt, xoa dịu',
          'options': ['Làm trầm trọng thêm', 'Làm giảm bớt, xoa dịu', 'Bắt buộc tuân thủ', 'Kích hoạt hệ thống'],
        },
        {
          'id': 'sv4',
          'word': 'Detrimental',
          'pos': 'adj',
          'phonetic': '/ˌdet.rɪˈmen.təl/',
          'correctMeaning': 'Gây hại, có hại',
          'options': ['Có lợi cho sức khỏe', 'Vô thưởng vô phạt', 'Gây hại, có hại', 'Thiết yếu, bắt buộc'],
        },
      ];

  // 7. Curated & Personal Flashcards (4 SRS Stages)
  static List<Map<String, dynamic>> get srsVocabCards => [
        {
          'id': 'v1',
          'word': 'Exacerbate',
          'pos': 'verb',
          'phonetic': '/ɪɡˈzæs.ə.beɪt/',
          'meaningVi': 'Làm trầm trọng thêm, làm xấu đi',
          'exampleEn': 'The economic crisis was exacerbated by a series of political scandals.',
          'exampleVi': 'Cuộc khủng hoảng kinh tế bị làm trầm trọng thêm bởi hàng loạt vụ bê bối chính trị.',
          'srsStage': 'LEARNING', // NEW, LEARNING, REVIEWING, MASTERED
          'targetBand': '7.5',
          'errorSource': 'WEB_WRITING', // NONE, WEB_READING, WEB_WRITING, MINI_GAME
          'synonyms': ['worsen', 'aggravate', 'intensify'],
          'repetitionCount': 2,
          'intervalDays': 3,
          'nextReviewAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': 'v2',
          'word': 'Plausible',
          'pos': 'adj',
          'phonetic': '/ˈplɔː.zə.bəl/',
          'meaningVi': 'Hợp lý, đáng tin cậy',
          'exampleEn': 'His explanation sounded plausible, but the researchers needed hard evidence.',
          'exampleVi': 'Lời giải thích của anh ấy nghe có vẻ hợp lý, nhưng các nhà nghiên cứu cần bằng chứng xác thực.',
          'srsStage': 'REVIEWING',
          'targetBand': '6.5',
          'errorSource': 'WEB_READING',
          'synonyms': ['reasonable', 'believable', 'credible'],
          'repetitionCount': 4,
          'intervalDays': 7,
          'nextReviewAt': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': 'v3',
          'word': 'Proponent',
          'pos': 'noun',
          'phonetic': '/prəˈpəʊ.nənt/',
          'meaningVi': 'Người ủng hộ, người đề xướng',
          'exampleEn': 'Proponents of green energy argue that renewable sources reduce global carbon emissions.',
          'exampleVi': 'Những người ủng hộ năng lượng xanh lập luận rằng các nguồn tái tạo giúp giảm phát thải carbon toàn cầu.',
          'srsStage': 'NEW',
          'targetBand': '6.5',
          'errorSource': 'NONE',
          'synonyms': ['advocate', 'supporter', 'champion'],
          'repetitionCount': 0,
          'intervalDays': 0,
          'nextReviewAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'v4',
          'word': 'Ephemeral',
          'pos': 'adj',
          'phonetic': '/ɪˈfem.ər.əl/',
          'meaningVi': 'Phù du, chóng tàn, ngắn ngủi',
          'exampleEn': 'Social media fame is often ephemeral, fading within a matter of weeks.',
          'exampleVi': 'Sự nổi tiếng trên mạng xã hội thường mang tính phù du, biến mất chỉ trong vài tuần.',
          'srsStage': 'MASTERED',
          'targetBand': '7.5',
          'errorSource': 'NONE',
          'synonyms': ['transient', 'fleeting', 'short-lived'],
          'repetitionCount': 6,
          'intervalDays': 28,
          'nextReviewAt': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        },
      ];

  // 8. Quick Speaking Prompt of the Day
  static Map<String, dynamic> get quickSpeakingDailyPrompt => {
        'id': 'spk_prompt_01',
        'questionPrompt': 'Do you prefer spending your free time alone or with other people? Why?',
        'topicCategory': 'Leisure & Socializing (Part 1)',
        'targetTimeSeconds': 45,
        'suggestedKeywords': ['unwind', 'recharge batteries', 'intimate gathering', 'solitude'],
      };

  // 9. AI Speaking Evaluation Mock Response (Matching Gemini 2.5 Flash format)
  static Map<String, dynamic> get quickSpeakingEvaluationMock => {
        'pronunciationScore': 6.5,
        'fluencyScore': 7.0,
        'overallScore': 6.5,
        'transcript':
            'To be honest, I prefer spending time alone when I want to recharge my batteries. Reading a good book or listening to classical music helps me unwind after a hectic day.',
        'mispronouncedWords': [
          {'word': 'hectic', 'ipa': '/ˈhek.tɪk/', 'tip': 'Nhấn trọng âm rõ vào âm tiết đầu tiên'},
          {'word': 'solitude', 'ipa': '/ˈsɒl.ɪ.tʃuːd/', 'tip': 'Phát âm đuôi /d/ dứt khoát'}
        ],
        'fillerWordsCount': 2,
        'shortFeedbackVi':
            'Độ trôi chảy tốt, ngữ điệu tự nhiên. Chú ý bật âm đuôi rõ hơn ở các từ có kết thúc là âm phụ âm bật.',
        'upgradedSampleBand75':
            'Frankly speaking, I gravitate toward solitude whenever I feel the urge to decompress. Engaging in solitary pastimes allows me to regain mental clarity after an overwhelming week.',
      };

  // 10. Weekly Leaderboards
  static Map<String, dynamic> get courseLeaderboard => {
        'courseId': 'course_lr_2605_001',
        'courseName': 'IELTS Chuyên sâu L/R 6.5+ (LR-2605-001)',
        'weekStartDate': '2026-11-02',
        'myRank': 3,
        'leaderboard': [
          {'rank': 1, 'name': 'Nguyễn Hà My', 'xp': 680, 'streak': 21, 'avatarUrl': null},
          {'rank': 2, 'name': 'Trần Gia Bảo', 'xp': 590, 'streak': 15, 'avatarUrl': null},
          {'rank': 3, 'name': 'Bạn (Học viên)', 'xp': 495, 'streak': 14, 'avatarUrl': null, 'isMe': true},
          {'rank': 4, 'name': 'Lê Minh Khôi', 'xp': 420, 'streak': 9, 'avatarUrl': null},
          {'rank': 5, 'name': 'Vũ Thảo Vy', 'xp': 380, 'streak': 12, 'avatarUrl': null},
          {'rank': 6, 'name': 'Đặng Quốc Huy', 'xp': 310, 'streak': 6, 'avatarUrl': null},
        ],
      };

  static Map<String, dynamic> get globalLeaderboard => {
        'weekStartDate': '2026-11-02',
        'myRank': 18,
        'leaderboard': [
          {'rank': 1, 'name': 'Hoàng Yến Nhi (K26)', 'xp': 1420, 'streak': 65, 'avatarUrl': null},
          {'rank': 2, 'name': 'Phạm Tuấn Anh (K25)', 'xp': 1250, 'streak': 48, 'avatarUrl': null},
          {'rank': 3, 'name': 'Nguyễn Thu Trang (K27)', 'xp': 1180, 'streak': 42, 'avatarUrl': null},
          {'rank': 4, 'name': 'Đỗ Đức Thắng (K26)', 'xp': 990, 'streak': 35, 'avatarUrl': null},
          {'rank': 5, 'name': 'Bùi Ngọc Lan (K26)', 'xp': 950, 'streak': 30, 'avatarUrl': null},
          {'rank': 18, 'name': 'Bạn (Học viên)', 'xp': 495, 'streak': 14, 'avatarUrl': null, 'isMe': true},
        ],
      };

  // 11. Curated Decks from Web Platform
  static List<Map<String, dynamic>> get defaultCuratedDecks => [
        {
          'id': 'deck_acad_01',
          'name': 'Oxford 3000 & 5000 Academic Core',
          'description': 'Bộ từ vựng học thuật cốt lõi giúp chinh phục Reading & Writing Band 6.5 - 7.5+',
          'totalWords': 120,
          'masteredWords': 42,
          'targetBand': '7.0',
          'category': 'Academic',
          'isCurated': true,
        },
        {
          'id': 'deck_env_02',
          'name': 'Environment & Climate Change Mastery',
          'description': 'Từ vựng chuyên đề môi trường, biến đổi khí hậu và phát triển bền vững',
          'totalWords': 85,
          'masteredWords': 30,
          'targetBand': '7.5',
          'category': 'Topic-based',
          'isCurated': true,
        },
        {
          'id': 'deck_tech_03',
          'name': 'Technology & Artificial Intelligence',
          'description': 'Các thuật ngữ và collocations cao cấp về công nghệ và trí tuệ nhân tạo',
          'totalWords': 90,
          'masteredWords': 18,
          'targetBand': '7.5',
          'category': 'Topic-based',
          'isCurated': true,
        },
        {
          'id': 'deck_edu_04',
          'name': 'Education & Modern Society',
          'description': 'Từ vựng trọng tâm về hệ thống giáo dục, phân tầng xã hội và định hướng nghề',
          'totalWords': 75,
          'masteredWords': 50,
          'targetBand': '6.5',
          'category': 'Topic-based',
          'isCurated': true,
        },
      ];
}
