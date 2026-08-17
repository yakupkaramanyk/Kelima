import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelima/core/router/app_router.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/core/utils/analytics_service.dart';
import 'package:kelima/firebase_options.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/l10n/locale_provider.dart';
import 'package:kelima/ui/widgets/error_view.dart';
import 'package:kelima/ui/widgets/offline_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global Error Handling ────────────────────────────────────────────────────
  
  // 1. Catch Flutter framework errors (widget errors, rendering errors)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
    
    // Log to analytics in production
    // AnalyticsService.logError(details.exception.toString(), details.stack);
  };

  // 2. Customize error widget for better UX
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(details: details);
  };

  // 3. Catch async errors not caught by Flutter (futures, isolates)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 Async Error: $error');
    debugPrint('Stack: $stack');
    
    // Log to analytics in production
    // AnalyticsService.logError(error.toString(), stack);
    
    return true; // Mark as handled
  };

  // ── Firebase Initialization ──────────────────────────────────────────────────
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Analytics
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e, stack) {
    debugPrint('🔴 Firebase init failed: $e');
    debugPrint('$stack');
    // Still run the app — show error state instead of blank screen
    runApp(const _FirebaseErrorApp());
    return;
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const KelimApp(),
    ),
  );
}

class KelimApp extends ConsumerWidget {
  const KelimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final analyticsObserver = ref.watch(analyticsObserverProvider);

    return MaterialApp.router(
      title: 'Kelima',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return Theme(
          data: AppTheme.light.copyWith(
            textTheme: GoogleFonts.nunitoTextTheme(
              AppTheme.light.textTheme,
            ),
          ),
          child: OfflineBanner(child: child!),
        );
      },
      routerConfig: router,
      // Track screen views automatically
      // GoRouter will notify this observer on every route change
    );
  }
}

/// Shown if Firebase fails to initialize — surfaces the error
/// instead of a blank white screen.
class _FirebaseErrorApp extends StatelessWidget {
  const _FirebaseErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFF7FAFE),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: 56, color: Color(0xFFE05C6D)),
                SizedBox(height: 20),
                Text(
                  'Firebase initialization failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2744),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check your Firebase config in firebase_options.dart\n'
                  'and make sure localhost is an authorized domain\n'
                  'in your Firebase project.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7A99),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
