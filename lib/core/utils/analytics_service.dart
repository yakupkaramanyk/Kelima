import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Analytics Service Provider
// ──────────────────────────────────────────────────────────────────────────────

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(FirebaseAnalytics.instance);
});

final analyticsObserverProvider = Provider<FirebaseAnalyticsObserver>((ref) {
  final analytics = ref.watch(analyticsServiceProvider).analytics;
  return FirebaseAnalyticsObserver(analytics: analytics);
});

// ──────────────────────────────────────────────────────────────────────────────
// Analytics Service
// ──────────────────────────────────────────────────────────────────────────────

class AnalyticsService {
  final FirebaseAnalytics analytics;

  AnalyticsService(this.analytics);

  // ── User Properties ────────────────────────────────────────────────────────

  Future<void> setUserProperties({
    required String userId,
    String? nativeLang,
    String? targetLang,
    String? learningGoal,
    int? dailyMinutes,
  }) async {
    await analytics.setUserId(id: userId);
    
    if (nativeLang != null) {
      await analytics.setUserProperty(name: 'native_lang', value: nativeLang);
    }
    if (targetLang != null) {
      await analytics.setUserProperty(name: 'target_lang', value: targetLang);
    }
    if (learningGoal != null) {
      await analytics.setUserProperty(name: 'learning_goal', value: learningGoal);
    }
    if (dailyMinutes != null) {
      await analytics.setUserProperty(
        name: 'daily_minutes',
        value: dailyMinutes.toString(),
      );
    }
  }

  // ── Onboarding Events ──────────────────────────────────────────────────────

  Future<void> logOnboardingStart() async {
    await analytics.logEvent(name: 'onboarding_start');
  }

  Future<void> logOnboardingStep({required int step, String? action}) async {
    await analytics.logEvent(
      name: 'onboarding_step',
      parameters: {
        'step_number': step,
        if (action != null) 'action': action,
      },
    );
  }

  Future<void> logOnboardingComplete({
    required String nativeLang,
    required String targetLang,
    required String goal,
    required int dailyMinutes,
  }) async {
    await analytics.logEvent(
      name: 'onboarding_complete',
      parameters: {
        'native_lang': nativeLang,
        'target_lang': targetLang,
        'goal': goal,
        'daily_minutes': dailyMinutes,
      },
    );
  }

  // ── Auth Events ────────────────────────────────────────────────────────────

  Future<void> logSignUp({required String method}) async {
    await analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogin({required String method}) async {
    await analytics.logLogin(loginMethod: method);
  }

  // ── Learning Session Events ────────────────────────────────────────────────

  Future<void> logSessionStart({
    required String targetLang,
    required int wordCount,
  }) async {
    await analytics.logEvent(
      name: 'session_start',
      parameters: {
        'target_lang': targetLang,
        'word_count': wordCount,
      },
    );
  }

  Future<void> logSessionComplete({
    required String targetLang,
    required int wordsLearned,
    required int easyCount,
    required int hardCount,
    required int forgotCount,
    required int durationSeconds,
  }) async {
    await analytics.logEvent(
      name: 'session_complete',
      parameters: {
        'target_lang': targetLang,
        'words_learned': wordsLearned,
        'easy_count': easyCount,
        'hard_count': hardCount,
        'forgot_count': forgotCount,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // ── Quiz Events ────────────────────────────────────────────────────────────

  Future<void> logQuizStart({
    required String quizType,
    required int questionCount,
  }) async {
    await analytics.logEvent(
      name: 'quiz_start',
      parameters: {
        'quiz_type': quizType,
        'question_count': questionCount,
      },
    );
  }

  Future<void> logQuizComplete({
    required String quizType,
    required int score,
    required int totalQuestions,
    required int durationSeconds,
  }) async {
    await analytics.logEvent(
      name: 'quiz_complete',
      parameters: {
        'quiz_type': quizType,
        'score': score,
        'total_questions': totalQuestions,
        'accuracy': totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // ── Engagement Events ──────────────────────────────────────────────────────

  Future<void> logDailyStreak({required int streakDays}) async {
    await analytics.logEvent(
      name: 'daily_streak',
      parameters: {'streak_days': streakDays},
    );
  }

  Future<void> logXpEarned({required int xpAmount, required String source}) async {
    await analytics.logEvent(
      name: 'xp_earned',
      parameters: {
        'xp_amount': xpAmount,
        'source': source, // 'session', 'quiz', 'streak_bonus', etc.
      },
    );
  }

  // ── Settings Events ────────────────────────────────────────────────────────

  Future<void> logLanguageChange({
    required String newTargetLang,
  }) async {
    await analytics.logEvent(
      name: 'language_change',
      parameters: {'new_target_lang': newTargetLang},
    );
  }

  Future<void> logDailyGoalChange({required int newMinutes}) async {
    await analytics.logEvent(
      name: 'daily_goal_change',
      parameters: {'new_minutes': newMinutes},
    );
  }

  // ── Screen Views (GoRouter otomatik handle eder, ama manuel de eklenebilir) ─

  Future<void> logScreenView({required String screenName}) async {
    await analytics.logScreenView(screenName: screenName);
  }

  // ── Custom Events ──────────────────────────────────────────────────────────

  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await analytics.logEvent(
      name: eventName,
      parameters: parameters?.cast<String, Object>(),
    );
  }
}
