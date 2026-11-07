class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate;
  final int freezeShields;
  final int maxFreezeShields;
  final int totalXp;
  final int dailyGoalXp;
  final int todayXp;
  final bool isCompletedToday;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    required this.freezeShields,
    required this.maxFreezeShields,
    required this.totalXp,
    required this.dailyGoalXp,
    required this.todayXp,
    required this.isCompletedToday,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastCompletedDate: json['lastCompletedDate'],
      freezeShields: json['freezeShields'] ?? 1,
      maxFreezeShields: json['maxFreezeShields'] ?? 3,
      totalXp: json['totalXp'] ?? 0,
      dailyGoalXp: json['dailyGoalXp'] ?? 50,
      todayXp: json['todayXp'] ?? 0,
      isCompletedToday: json['isCompletedToday'] ?? false,
    );
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
    int? freezeShields,
    int? maxFreezeShields,
    int? totalXp,
    int? dailyGoalXp,
    int? todayXp,
    bool? isCompletedToday,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      freezeShields: freezeShields ?? this.freezeShields,
      maxFreezeShields: maxFreezeShields ?? this.maxFreezeShields,
      totalXp: totalXp ?? this.totalXp,
      dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
      todayXp: todayXp ?? this.todayXp,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }
}
