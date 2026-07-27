int wordsPerSession(int dailyMinutes) {
  if (dailyMinutes <= 5) return 3;
  if (dailyMinutes <= 10) return 7;
  if (dailyMinutes <= 15) return 10;
  return 20;
}

class UserStatsModel {
  final int streakCount;
  final String? lastActivityDate;
  final int totalXP;
  final int todayWordsLearned;
  final int todayGoal;

  const UserStatsModel({
    required this.streakCount,
    this.lastActivityDate,
    required this.totalXP,
    required this.todayWordsLearned,
    required this.todayGoal,
  });

  factory UserStatsModel.empty({int dailyMinutes = 10}) => UserStatsModel(
        streakCount: 0,
        lastActivityDate: null,
        totalXP: 0,
        todayWordsLearned: 0,
        todayGoal: wordsPerSession(dailyMinutes),
      );

  factory UserStatsModel.fromMap(Map<String, dynamic> map, {int dailyMinutes = 10}) {
    return UserStatsModel(
      streakCount: map['streakCount'] as int? ?? 0,
      lastActivityDate: map['lastActivityDate'] as String?,
      totalXP: map['totalXP'] as int? ?? 0,
      todayWordsLearned: map['todayWordsLearned'] as int? ?? 0,
      todayGoal: wordsPerSession(dailyMinutes),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streakCount': streakCount,
      if (lastActivityDate != null) 'lastActivityDate': lastActivityDate,
      'totalXP': totalXP,
      'todayWordsLearned': todayWordsLearned,
      'todayGoal': todayGoal,
    };
  }

  UserStatsModel copyWith({
    int? streakCount,
    String? lastActivityDate,
    int? totalXP,
    int? todayWordsLearned,
    int? todayGoal,
  }) {
    return UserStatsModel(
      streakCount: streakCount ?? this.streakCount,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      totalXP: totalXP ?? this.totalXP,
      todayWordsLearned: todayWordsLearned ?? this.todayWordsLearned,
      todayGoal: todayGoal ?? this.todayGoal,
    );
  }
}
