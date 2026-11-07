import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'The IELTS Spells';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Supabase Auth Config (Matches Next.js .env.local)
  static const String supabaseUrl = 'https://uhicxsohrlisbgtwdmld.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVoaWN4c29ocmxpc2JndHdkbWxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA5OTQ1NDcsImV4cCI6MjEwNjU3MDU0N30.pNr55Sreqgc9paSB4aXCFATL8bXBoaCYJL58KnUCTME';

  // Backend API Base URL
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    // Default Android emulator loopback
    return 'http://10.0.2.2:8080/api/v1';
  }

  // Gamification Constants
  static const int defaultDailyGoalXp = 100;
  static const int xpPerFlashcard = 5;
  static const int xpPerMiniGame = 25;
  static const int xpPerSpeakingAttempt = 30;
  static const int xpPerStreakDay = 20;
}
