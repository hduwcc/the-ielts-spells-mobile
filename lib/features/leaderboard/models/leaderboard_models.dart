class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final int streak;
  final String? avatarUrl;
  final bool isMe;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.streak,
    this.avatarUrl,
    this.isMe = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      xp: json['xp'] ?? 0,
      streak: json['streak'] ?? 0,
      avatarUrl: json['avatarUrl'],
      isMe: json['isMe'] ?? false,
    );
  }
}
