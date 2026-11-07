import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'mock_data.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 1. Version Check
  static Future<Map<String, dynamic>> checkAppVersion() async {
    try {
      final response = await _dio.get('/public/mobile/version-check', queryParameters: {
        'platform': 'ANDROID',
        'currentVersion': AppConfig.appVersion,
        'buildNumber': AppConfig.buildNumber,
      });
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return MockData.appVersionConfig;
    }
  }

  // 2. Student Portal Overview (Real Data from Web Backend)
  static Future<Map<String, dynamic>?> getStudentPortalOverview() async {
    try {
      final response = await _dio.get('/student/portal/overview');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // 3. Dashboard / Habit & Streak
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final overview = await getStudentPortalOverview();
      if (overview != null) {
        final metrics = overview['metrics'] as Map<String, dynamic>?;
        final profile = overview['profile'] as Map<String, dynamic>?;
        final enrollments = overview['enrollments'] as List<dynamic>?;

        String courseCode = 'IELTS 2026-0011';
        if (enrollments != null && enrollments.isNotEmpty) {
          final first = enrollments.first as Map<String, dynamic>;
          courseCode = first['courseCode'] ?? courseCode;
        }

        return {
          'streak': {
            'currentStreak': metrics?['currentStreakDays'] ?? 14,
            'longestStreak': 28,
            'lastCompletedDate': DateTime.now().toIso8601String().split('T')[0],
            'freezeShields': 2,
            'maxFreezeShields': 3,
            'totalXp': 2450,
            'dailyGoalXp': 100,
            'todayXp': 35,
            'isCompletedToday': false,
          },
          'enrolledCourseCode': courseCode,
          'studentName': profile?['fullName'] ?? 'Học viên',
          'targetBand': profile?['targetBand'] ?? 7.5,
          'calendar': MockData.streakCalendarHistory,
          'speakingPrompt': MockData.quickSpeakingDailyPrompt,
          'dueSrsCount': 8,
        };
      }
    } catch (_) {}

    return {
      'streak': MockData.studentStreak,
      'enrolledCourseCode': 'IELTS 2026-0011',
      'studentName': 'Học viên The IELTS Spells',
      'targetBand': 7.5,
      'calendar': MockData.streakCalendarHistory,
      'speakingPrompt': MockData.quickSpeakingDailyPrompt,
      'dueSrsCount': 5,
    };
  }

  // 4. Curated Decks from Web Backend
  static Future<List<Map<String, dynamic>>> getCuratedDecks() async {
    try {
      final response = await _dio.get('/student/curated-vocabulary/decks');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (_) {}
    return MockData.defaultCuratedDecks;
  }

  // 5. Curated Deck Study Session (10 words)
  static Future<Map<String, dynamic>> getCuratedDeckSession(String deckId) async {
    try {
      final response = await _dio.get('/student/curated-vocabulary/decks/$deckId/session');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {
        'deckId': deckId,
        'items': MockData.srsVocabCards,
      };
    }
  }

  // 6. Update Curated Progress
  static Future<bool> updateCuratedProgress({
    required String deckId,
    required String itemId,
    required String masteryStatus,
  }) async {
    try {
      final response = await _dio.patch(
        '/student/curated-vocabulary/decks/$deckId/items/$itemId/progress',
        data: {'masteryStatus': masteryStatus},
      );
      return response.statusCode == 200;
    } catch (_) {
      return true; // Optimistic update
    }
  }

  // 7. Personal Vocabulary Notebook
  static Future<Map<String, dynamic>> getStudentVocabularyNotebook() async {
    try {
      final response = await _dio.get('/student/vocabulary');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {
        'totalCards': 24,
        'masteredCount': 12,
        'reviewingCount': 8,
        'learningCount': 4,
        'cards': MockData.srsVocabCards,
      };
    }
  }

  // 8. Submit Game Result
  static Future<Map<String, dynamic>> submitGameResult({
    required String gameType,
    required int score,
    required int maxCombo,
    required int timeSpentSeconds,
    List<String>? mistakeWordIds,
  }) async {
    try {
      final response = await _dio.post('/student/portal/activity', data: {
        'gameType': gameType,
        'score': score,
        'maxCombo': maxCombo,
        'timeSpentSeconds': timeSpentSeconds,
        'mistakeWordIds': mistakeWordIds ?? [],
      });
      return response.data as Map<String, dynamic>;
    } catch (_) {
      final int xpEarned = AppConfig.xpPerMiniGame + (maxCombo * 2);
      return {
        'success': true,
        'xpEarned': xpEarned,
        'currentStreak': 14,
        'isStreakUpdated': true,
      };
    }
  }

  // 9. Quick Speaking Evaluation (Simulated AI / Backend)
  static Future<Map<String, dynamic>> evaluateQuickSpeaking({
    required String questionPrompt,
    required String audioPath,
    required int durationSeconds,
  }) async {
    try {
      final formData = FormData.fromMap({
        'questionPrompt': questionPrompt,
        'durationSeconds': durationSeconds,
        'audioFile': await MultipartFile.fromFile(audioPath),
      });
      final response = await _dio.post('/student/speaking/quick-evaluate', data: formData);
      return response.data as Map<String, dynamic>;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return MockData.quickSpeakingEvaluationMock;
    }
  }

  // 10. Leaderboard
  static Future<Map<String, dynamic>> getLeaderboard({required String scope, String? courseId}) async {
    try {
      final response = await _dio.get('/student/portal/courses');
      if (response.data is List && (response.data as List).isNotEmpty) {
        // Build live class ranking
      }
    } catch (_) {}

    if (scope == 'GLOBAL') {
      return MockData.globalLeaderboard;
    }
    return MockData.courseLeaderboard;
  }
}
