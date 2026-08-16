class AppConstants {
  AppConstants._();

  // ──────────────────────────────────────────
  // Languages
  // ──────────────────────────────────────────
  static const List<LanguageOption> languages = [
    LanguageOption(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
    LanguageOption(code: 'en', name: 'English', flag: '🇬🇧'),
    LanguageOption(code: 'nl', name: 'Nederlands', flag: '🇳🇱'),
    LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'fr', name: 'Français', flag: '🇫🇷'),
  ];

  // ──────────────────────────────────────────
  // Learning Goals
  // ──────────────────────────────────────────
  static const List<GoalOption> learningGoals = [
    GoalOption(code: 'travel', label: 'Travel', emoji: '✈️'),
    GoalOption(code: 'work', label: 'Work', emoji: '💼'),
    GoalOption(code: 'education', label: 'Education', emoji: '🎓'),
    GoalOption(code: 'personal', label: 'Personal Interest', emoji: '❤️'),
    GoalOption(code: 'visa_exam', label: 'Spouse Visa Prep', emoji: '🛂'),
  ];

  // ──────────────────────────────────────────
  // Daily Study Time
  // ──────────────────────────────────────────
  static const List<TimeOption> studyTimes = [
    TimeOption(minutes: 5, label: '5 min', description: 'Quick daily habit'),
    TimeOption(minutes: 10, label: '10 min', description: 'Steady progress'),
    TimeOption(minutes: 15, label: '15 min', description: 'Solid commitment'),
    TimeOption(minutes: 30, label: '30 min', description: 'Serious learner'),
  ];

  // ──────────────────────────────────────────
  // Shared Preferences Keys
  // ──────────────────────────────────────────
  static const String kOnboardingComplete = 'onboarding_complete';

  // ──────────────────────────────────────────
  // Onboarding
  // ──────────────────────────────────────────
  static const int totalOnboardingSteps = 5;
}

// ──────────────────────────────────────────
// Value Objects
// ──────────────────────────────────────────

class LanguageOption {
  final String code;
  final String name;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class GoalOption {
  final String code;
  final String label;
  final String emoji;

  const GoalOption({
    required this.code,
    required this.label,
    required this.emoji,
  });
}

class TimeOption {
  final int minutes;
  final String label;
  final String description;

  const TimeOption({
    required this.minutes,
    required this.label,
    required this.description,
  });
}
