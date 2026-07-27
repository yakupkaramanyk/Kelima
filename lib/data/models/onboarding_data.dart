import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingData {
  final String displayName;
  final String nativeLanguage;
  final String targetLanguage;
  final String learningGoal;
  final int dailyMinutes;
  final DateTime? createdAt;

  const OnboardingData({
    required this.displayName,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.learningGoal,
    required this.dailyMinutes,
    this.createdAt,
  });

  OnboardingData copyWith({
    String? displayName,
    String? nativeLanguage,
    String? targetLanguage,
    String? learningGoal,
    int? dailyMinutes,
    DateTime? createdAt,
  }) {
    return OnboardingData(
      displayName: displayName ?? this.displayName,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      learningGoal: learningGoal ?? this.learningGoal,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'nativeLanguage': nativeLanguage,
      'targetLanguage': targetLanguage,
      'learningGoal': learningGoal,
      'dailyMinutes': dailyMinutes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory OnboardingData.fromFirestore(Map<String, dynamic> map) {
    return OnboardingData(
      displayName: map['displayName'] as String? ?? '',
      nativeLanguage: map['nativeLanguage'] as String? ?? '',
      targetLanguage: map['targetLanguage'] as String? ?? '',
      learningGoal: map['learningGoal'] as String? ?? '',
      dailyMinutes: map['dailyMinutes'] as int? ?? 5,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isComplete =>
      displayName.isNotEmpty &&
      nativeLanguage.isNotEmpty &&
      targetLanguage.isNotEmpty &&
      learningGoal.isNotEmpty &&
      dailyMinutes > 0;

  @override
  String toString() =>
      'OnboardingData(native: $nativeLanguage, target: $targetLanguage, '
      'goal: $learningGoal, minutes: $dailyMinutes)';
}
