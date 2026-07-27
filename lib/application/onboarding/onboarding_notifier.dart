import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/data/models/onboarding_data.dart';

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

// ──────────────────────────────────────────
// State
// ──────────────────────────────────────────

class OnboardingState {
  final int currentStep; // 0-indexed (0..5) — now 6 steps
  final String? displayName;
  final String? nativeLanguage;
  final String? targetLanguage;
  final String? learningGoal;
  final int? dailyMinutes;

  const OnboardingState({
    this.currentStep = 0,
    this.displayName,
    this.nativeLanguage,
    this.targetLanguage,
    this.learningGoal,
    this.dailyMinutes,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? displayName,
    String? nativeLanguage,
    String? targetLanguage,
    String? learningGoal,
    int? dailyMinutes,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      displayName: displayName ?? this.displayName,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      learningGoal: learningGoal ?? this.learningGoal,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    );
  }

  /// Build the final OnboardingData model (only safe to call when all fields are set)
  OnboardingData toOnboardingData() {
    return OnboardingData(
      displayName: displayName!,
      nativeLanguage: nativeLanguage!,
      targetLanguage: targetLanguage!,
      learningGoal: learningGoal!,
      dailyMinutes: dailyMinutes!,
    );
  }

  bool get isReadyToSubmit =>
      displayName != null &&
      nativeLanguage != null &&
      targetLanguage != null &&
      learningGoal != null &&
      dailyMinutes != null;
}

// ──────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setDisplayName(String name) {
    state = state.copyWith(displayName: name.trim());
  }

  void selectNativeLanguage(String code) {
    state = state.copyWith(nativeLanguage: code);
  }

  void selectTargetLanguage(String code) {
    state = state.copyWith(targetLanguage: code);
  }

  void selectGoal(String code) {
    state = state.copyWith(learningGoal: code);
  }

  void selectDailyMinutes(int minutes) {
    state = state.copyWith(dailyMinutes: minutes);
  }

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void reset() {
    state = const OnboardingState();
  }
}
