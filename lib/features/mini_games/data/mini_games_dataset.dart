enum GameDifficulty { easy, medium, hard }

extension GameDifficultyExtension on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Dễ (Band 5.0 - 6.0)';
      case GameDifficulty.medium:
        return 'Trung bình (Band 6.5 - 7.0)';
      case GameDifficulty.hard:
        return 'Khó (Band 7.5 - 8.5+)';
    }
  }

  String get shortLabel {
    switch (this) {
      case GameDifficulty.easy:
        return 'Dễ';
      case GameDifficulty.medium:
        return 'Vừa';
      case GameDifficulty.hard:
        return 'Khó';
    }
  }
}

class MiniGamesDataset {
  // ==========================================
  // 1. COLLOCATION HUNTER DATASET
  // ==========================================

  static List<Map<String, String>> getCollocations(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return [
          {'left': 'make', 'right': 'a big decision'},
          {'left': 'take', 'right': 'detailed notes'},
          {'left': 'pay', 'right': 'close attention'},
          {'left': 'gain', 'right': 'valuable knowledge'},
          {'left': 'catch', 'right': 'someone\'s attention'},
          {'left': 'give', 'right': 'helpful advice'},
          {'left': 'save', 'right': 'precious time'},
          {'left': 'reach', 'right': 'a final agreement'},
          {'left': 'raise', 'right': 'public awareness'},
          {'left': 'broaden', 'right': 'one\'s horizons'},
          {'left': 'set', 'right': 'a realistic goal'},
          {'left': 'break', 'right': 'a bad habit'},
        ];

      case GameDifficulty.medium:
        return [
          {'left': 'pose', 'right': 'a serious threat'},
          {'left': 'deeply', 'right': 'rooted in culture'},
          {'left': 'exert', 'right': 'a profound impact'},
          {'left': 'bridge', 'right': 'the generation gap'},
          {'left': 'foster', 'right': 'creativity and innovation'},
          {'left': 'pave', 'right': 'the way for progress'},
          {'left': 'yield', 'right': 'promising results'},
          {'left': 'bear', 'right': 'full responsibility'},
          {'left': 'draw', 'right': 'a valid conclusion'},
          {'left': 'reach', 'right': 'a broad consensus'},
          {'left': 'address', 'right': 'a pressing concern'},
          {'left': 'allocate', 'right': 'national resources'},
          {'left': 'fulfill', 'right': 'academic criteria'},
          {'left': 'curb', 'right': 'environmental pollution'},
        ];

      case GameDifficulty.hard:
        return [
          {'left': 'wreak', 'right': 'havoc on biodiversity'},
          {'left': 'shed', 'right': 'light on the enigma'},
          {'left': 'cast', 'right': 'doubt on the theory'},
          {'left': 'grapple', 'right': 'with dire consequences'},
          {'left': 'run', 'right': 'contrary to popular belief'},
          {'left': 'exercise', 'right': 'utmost restraint'},
          {'left': 'strike', 'right': 'a delicate balance'},
          {'left': 'reap', 'right': 'tangible benefits'},
          {'left': 'precipitate', 'right': 'an economic downfall'},
          {'left': 'engender', 'right': 'mutual understanding'},
          {'left': 'stem', 'right': 'from systemic flaws'},
          {'left': 'hinge', 'right': 'on multilateral cooperation'},
          {'left': 'catalyze', 'right': 'technological breakthrough'},
          {'left': 'herald', 'right': 'a new digital era'},
        ];
    }
  }

  // ==========================================
  // 2. GRAMMAR DETECTIVE DATASET
  // ==========================================

  static List<Map<String, dynamic>> getGrammarItems(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return [
          {
            'id': 'ge1',
            'tokens': ['She', 'go', 'to', 'the', 'library', 'every', 'Saturday', 'morning.'],
            'errorIndex': 1,
            'correctedToken': 'goes',
            'category': 'Subject-Verb Agreement',
            'explanationVi': 'Chủ ngữ "She" ở thì hiện tại đơn đi kèm động từ thêm -s/-es ("goes").',
          },
          {
            'id': 'ge2',
            'tokens': ['There', 'are', 'a', 'lot', 'of', 'informations', 'on', 'the', 'website.'],
            'errorIndex': 5,
            'correctedToken': 'information',
            'category': 'Uncountable Noun',
            'explanationVi': '"Information" là danh từ không đếm được trong tiếng Anh, tuyệt đối không thêm số nhiều "s".',
          },
          {
            'id': 'ge3',
            'tokens': ['He', 'is', 'interested', 'on', 'learning', 'foreign', 'languages.'],
            'errorIndex': 3,
            'correctedToken': 'in',
            'category': 'Preposition Error',
            'explanationVi': 'Cụm từ chuẩn là "interested in something" (thích thú điều gì), không đi với giới từ "on".',
          },
          {
            'id': 'ge4',
            'tokens': ['Many', 'people', 'enjoys', 'watching', 'movies', 'at', 'home.'],
            'errorIndex': 2,
            'correctedToken': 'enjoy',
            'category': 'Subject-Verb Agreement',
            'explanationVi': '"People" là danh từ số nhiều, vì vậy động từ phải ở dạng nguyên mẫu "enjoy".',
          },
        ];

      case GameDifficulty.medium:
        return [
          {
            'id': 'gm1',
            'tokens': ['The', 'number', 'of', 'vehicles', 'have', 'surged', 'dramatically', 'recently.'],
            'errorIndex': 4,
            'correctedToken': 'has',
            'category': 'Subject-Verb Agreement',
            'explanationVi': '"The number of + danh từ số nhiều" đi với động từ số ít ("has surged"), chỉ có "A number of" mới đi với số nhiều.',
          },
          {
            'id': 'gm2',
            'tokens': ['Despite', 'of', 'studying', 'hard,', 'she', 'could', 'not', 'pass', 'the', 'test.'],
            'errorIndex': 1,
            'correctedToken': '',
            'category': 'Preposition Error',
            'explanationVi': 'Sau "Despite" không có "of" (Despite + N/V-ing). Chỉ "In spite of" mới dùng giới từ "of".',
          },
          {
            'id': 'gm3',
            'tokens': ['Technology', 'allows', 'people', 'communicating', 'easily', 'across', 'borders.'],
            'errorIndex': 3,
            'correctedToken': 'to communicate',
            'category': 'Verb Pattern',
            'explanationVi': 'Cấu trúc chuẩn là "allow someone TO DO something", không dùng trực tiếp dạng V-ing.',
          },
          {
            'id': 'gm4',
            'tokens': ['Governments', 'should', 'prioritize', 'invest', 'in', 'clean', 'energy.'],
            'errorIndex': 3,
            'correctedToken': 'investing',
            'category': 'Gerund vs Infinitive',
            'explanationVi': 'Động từ "prioritize" luôn đi kèm với danh từ hoặc danh động từ V-ing ("prioritize investing").',
          },
        ];

      case GameDifficulty.hard:
        return [
          {
            'id': 'gh1',
            'tokens': ['Hardly', 'had', 'the', 'lecture', 'started', 'than', 'the', 'fire', 'alarm', 'rang.'],
            'errorIndex': 5,
            'correctedToken': 'when',
            'category': 'Negative Inversion',
            'explanationVi': 'Cấu trúc đảo ngữ chuẩn: "Hardly had + S + V3 WHEN + S + V-ed". Chỉ "No sooner" mới đi với "than".',
          },
          {
            'id': 'gh2',
            'tokens': ['The', 'board', 'demanded', 'that', 'every', 'employee', 'is', 'punctual.'],
            'errorIndex': 6,
            'correctedToken': 'be',
            'category': 'Subjunctive Mood',
            'explanationVi': 'Trong mệnh đề giả định sau "demanded that...", động từ phải ở dạng nguyên thể không "to" ("be punctual").',
          },
          {
            'id': 'gh3',
            'tokens': ['Not', 'only', 'she', 'finished', 'the', 'essay,', 'but', 'she', 'also', 'excelled.'],
            'errorIndex': 2,
            'correctedToken': 'did she finish',
            'category': 'Fronting Inversion',
            'explanationVi': 'Khi cụm "Not only" đứng đầu câu, mệnh đề đầu tiên bắt buộc phải đảo ngữ ("Not only did she finish...").',
          },
          {
            'id': 'gh4',
            'tokens': ['Walking', 'through', 'the', 'park,', 'a', 'heavy', 'rain', 'suddenly', 'began.'],
            'errorIndex': 4,
            'correctedToken': 'we were caught in',
            'category': 'Dangling Modifier',
            'explanationVi': 'Lỗi phân từ treo (Dangling participle): Cơn mưa không thể "đi bộ qua công viên". Chủ ngữ chính phải là người đi bộ.',
          },
        ];
    }
  }

  // ==========================================
  // 3. SPEED VOCAB DATASET
  // ==========================================

  static List<Map<String, dynamic>> getSpeedVocabItems(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return [
          {
            'id': 'sve1',
            'word': 'Crucial',
            'pos': 'adj',
            'phonetic': '/ˈkruː.ʃəl/',
            'correctMeaning': 'Cực kỳ quan trọng, quyết định',
            'options': ['Bình thường, dễ dãi', 'Cực kỳ quan trọng, quyết định', 'Nguy hiểm, độc hại', 'Tạm thời, ngắn ngủi'],
          },
          {
            'id': 'sve2',
            'word': 'Acquire',
            'pos': 'v',
            'phonetic': '/əˈkwaɪər/',
            'correctMeaning': 'Đạt được, thu nhận được',
            'options': ['Đánh mất, làm hỏng', 'Trì hoãn thời gian', 'Đạt được, thu nhận được', 'Từ chối dứt khoát'],
          },
          {
            'id': 'sve3',
            'word': 'Efficient',
            'pos': 'adj',
            'phonetic': '/ɪˈfɪʃ.ənt/',
            'correctMeaning': 'Hiệu quả, năng suất cao',
            'options': ['Hiệu quả, năng suất cao', 'Chậm chạp, lề mề', 'Tốn kém chi phí', 'Phức tạp, rắc rối'],
          },
          {
            'id': 'sve4',
            'word': 'Benefit',
            'pos': 'n',
            'phonetic': '/ˈben.ɪ.fɪt/',
            'correctMeaning': 'Lợi ích, thuận lợi',
            'options': ['Tác hại, rủi ro', 'Lợi ích, thuận lợi', 'Khoản nợ lớn', 'Trở ngại ban đầu'],
          },
        ];

      case GameDifficulty.medium:
        return [
          {
            'id': 'svm1',
            'word': 'Procrastinate',
            'pos': 'v',
            'phonetic': '/prəˈkræs.tɪ.neɪt/',
            'correctMeaning': 'Trì hoãn, chần chừ',
            'options': ['Thúc đẩy tiến độ', 'Trì hoãn, chần chừ', 'Hợp tác chặt chẽ', 'Phân chia tài nguyên'],
          },
          {
            'id': 'svm2',
            'word': 'Ubiquitous',
            'pos': 'adj',
            'phonetic': '/juːˈbɪk.wə.təs/',
            'correctMeaning': 'Phổ biến, ở đâu cũng có',
            'options': ['Hiếm gặp, quý giá', 'Tạm thời, ngắn ngủi', 'Phổ biến, ở đâu cũng có', 'Nghiêm khắc, ngặt nghèo'],
          },
          {
            'id': 'svm3',
            'word': 'Mitigate',
            'pos': 'v',
            'phonetic': '/ˈmɪt.ɪ.ɡeɪt/',
            'correctMeaning': 'Làm giảm bớt, xoa dịu',
            'options': ['Làm trầm trọng thêm', 'Làm giảm bớt, xoa dịu', 'Bắt buộc tuân thủ', 'Kích hoạt hệ thống'],
          },
          {
            'id': 'svm4',
            'word': 'Detrimental',
            'pos': 'adj',
            'phonetic': '/ˌdet.rɪˈmen.təl/',
            'correctMeaning': 'Gây hại, có hại',
            'options': ['Có lợi cho sức khỏe', 'Vô thưởng vô phạt', 'Gây hại, có hại', 'Thiết yếu, bắt buộc'],
          },
        ];

      case GameDifficulty.hard:
        return [
          {
            'id': 'svh1',
            'word': 'Ephemeral',
            'pos': 'adj',
            'phonetic': '/ɪˈfem.ər.əl/',
            'correctMeaning': 'Phù du, chóng tàn, ngắn ngủi',
            'options': ['Bất diệt, vĩnh hằng', 'Phù du, chóng tàn, ngắn ngủi', 'Vững chắc như núi', 'Lan rộng khắp nơi'],
          },
          {
            'id': 'svh2',
            'word': 'Exacerbate',
            'pos': 'v',
            'phonetic': '/ɪɡˈzæs.ə.beɪt/',
            'correctMeaning': 'Làm trầm trọng thêm tình hình',
            'options': ['Xoa dịu mâu thuẫn', 'Làm trầm trọng thêm tình hình', 'Thống kê số liệu', 'Phê bình nghiêm khắc'],
          },
          {
            'id': 'svh3',
            'word': 'Equivocal',
            'pos': 'adj',
            'phonetic': '/ɪˈkwɪv.ə.kəl/',
            'correctMeaning': 'Mập mờ, nước đôi, không rõ ràng',
            'options': ['Chính xác tuyệt đối', 'Đồng thuận cao', 'Mập mờ, nước đôi, không rõ ràng', 'Dứt khoát, minh bạch'],
          },
          {
            'id': 'svh4',
            'word': 'Pernicious',
            'pos': 'adj',
            'phonetic': '/pəˈnɪʃ.əs/',
            'correctMeaning': 'Hiểm hại, gây tác hại âm thầm',
            'options': ['Hiểm hại, gây tác hại âm thầm', 'Rực rỡ, lộng lẫy', 'Khoan dung, độ lượng', 'Bất ngờ, đột ngột'],
          },
        ];
    }
  }
}
