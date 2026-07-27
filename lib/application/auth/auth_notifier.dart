import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/data/repositories/auth_repository.dart';
import 'package:kelima/data/repositories/user_repository.dart';
import 'package:kelima/data/models/onboarding_data.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthNotifierState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(userRepositoryProvider),
  );
});

// ──────────────────────────────────────────
// State
// ──────────────────────────────────────────

enum AuthStatus { idle, loading, success, error }

class AuthNotifierState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthNotifierState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  AuthNotifierState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthNotifierState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
}

// ──────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthNotifierState> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthNotifier(this._authRepo, this._userRepo)
      : super(const AuthNotifierState());

  /// Sign up + save onboarding data to Firestore
  Future<bool> createAccountAndSaveOnboarding({
    required String email,
    required String password,
    String? displayName,
    required OnboardingData onboardingData,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final credential = await _authRepo.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      final uid = credential.user!.uid;

      await _userRepo.saveOnboardingData(
        uid: uid,
        data: onboardingData,
      );

      state = state.copyWith(status: AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthRepository.parseAuthError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Sign in existing user
  Future<bool> signIn({
    required String email,
    required String password,
    OnboardingData? onboardingData,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final credential = await _authRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (onboardingData != null && credential.user != null) {
        await _userRepo.saveOnboardingData(
          uid: credential.user!.uid,
          data: onboardingData,
        );
      }
      
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthRepository.parseAuthError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.idle, errorMessage: null);
  }
}
