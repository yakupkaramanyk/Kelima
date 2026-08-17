import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kelima/core/utils/analytics_service.dart';
import 'package:kelima/data/repositories/auth_repository.dart';
import 'package:kelima/ui/screens/onboarding/onboarding_shell.dart';
import 'package:kelima/ui/screens/quiz/quiz_screen.dart';
import 'package:kelima/ui/screens/shell/main_shell.dart';
import 'package:kelima/ui/screens/word_session/word_session_screen.dart';
import 'package:kelima/ui/screens/settings/settings_screen.dart' as kelima_settings;

// ──────────────────────────────────────────
// Route names
// ──────────────────────────────────────────
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String session = '/session';
  static const String quiz = '/quiz';
}

// ──────────────────────────────────────────
// GoRouter refresh notifier — wraps the Firebase auth stream.
// The SAME GoRouter instance is kept alive; redirect is re-evaluated
// whenever auth state changes, instead of creating a new router.
// ──────────────────────────────────────────
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Stream<User?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ──────────────────────────────────────────
// Router provider
// ──────────────────────────────────────────
final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  final notifier = _AuthChangeNotifier(authRepo.authStateChanges);
  final analyticsObserver = ref.read(analyticsObserverProvider);

  // Clean up the notifier when the provider is disposed
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    observers: [analyticsObserver],
    // refreshListenable triggers redirect re-evaluation on auth change
    // WITHOUT recreating the GoRouter instance.
    refreshListenable: notifier,
    redirect: (context, state) {
      // Read current user synchronously — no async race condition
      final isLoggedIn = authRepo.currentUser != null;
      final isOnboarding =
          state.matchedLocation.startsWith(AppRoutes.onboarding);
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // Root: decide initial destination
      if (isSplash) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.onboarding;
      }

      // Logged in → don't stay on onboarding
      if (isLoggedIn && isOnboarding) {
        return AppRoutes.home;
      }

      // Not logged in → don't stay on home
      if (!isLoggedIn && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashRedirect(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingShell(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const WordSessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const kelima_settings.SettingsScreen(),
      ),
      GoRoute(
        path: '/settings_flow',
        builder: (context, state) => const kelima_settings.SettingsFlowShell(),
      ),
    ],
  );
});

// ──────────────────────────────────────────
// Splash — shown briefly during the initial auth check
// ──────────────────────────────────────────
class _SplashRedirect extends StatelessWidget {
  const _SplashRedirect();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7FAFE),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A90D9),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
