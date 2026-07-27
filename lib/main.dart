import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelima/core/router/app_router.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/firebase_options.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/l10n/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any startup errors and surface them instead of blank screen
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('Firebase init failed: $e');
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
          child: child!,
        );
      },
      routerConfig: router,
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
