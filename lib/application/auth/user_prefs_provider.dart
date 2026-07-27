import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/auth/auth_provider.dart';
import 'package:kelima/core/l10n/locale_provider.dart';
import 'package:kelima/data/repositories/user_repository.dart';

// ── User language preferences ─────────────────────────────────────────────────

class UserLangPrefs {
  final String displayName;
  final String nativeLang;
  final String targetLang;
  final int dailyMinutes;

  const UserLangPrefs({
    required this.displayName,
    required this.nativeLang,
    required this.targetLang,
    this.dailyMinutes = 10,
  });

  static String flagFor(String code) {
    switch (code) {
      case 'tr': return '🇹🇷';
      case 'en': return '🇬🇧';
      case 'nl': return '🇳🇱';
      case 'de': return '🇩🇪';
      case 'fr': return '🇫🇷';
      default:   return '🏳️';
    }
  }

  static String ttsLocaleFor(String code) {
    switch (code) {
      case 'tr': return 'tr-TR';
      case 'en': return 'en-US';
      case 'nl': return 'nl-NL';
      case 'de': return 'de-DE';
      case 'fr': return 'fr-FR';
      default:   return 'en-US';
    }
  }

  @override
  String toString() => 'UserLangPrefs(target=$targetLang, native=$nativeLang, dailyMinutes=$dailyMinutes)';
}

// ── Provider ──────────────────────────────────────────────────────────────────
//
// Watches authStateProvider (a StreamProvider) so it correctly waits for
// Firebase Auth to restore the session on Flutter Web before reading Firestore.
// Without this, currentUser is null at startup → fallback always used.

final userLangPrefsProvider = FutureProvider<UserLangPrefs>((ref) async {
  // Wait for Firebase Auth to emit the first definitive user state.
  // authStateProvider is a StreamProvider — .future resolves when the first
  // non-loading value is available (either User or null).
  final user = await ref.watch(authStateProvider.future);

  debugPrint('🔑 userLangPrefsProvider: uid=${user?.uid}');

  if (user == null) {
    debugPrint('⚠️  Not logged in — using fallback');
    return const UserLangPrefs(displayName: '', nativeLang: 'tr', targetLang: 'nl', dailyMinutes: 10);
  }

  final repo = ref.read(userRepositoryProvider);
  final data = await repo.getOnboardingData(user.uid);

  debugPrint('📄 Firestore raw: nativeLanguage=${data?.nativeLanguage}, targetLanguage=${data?.targetLanguage}');
  // User request: temporary debugPrint
  debugPrint('targetLang from Firestore: ${data?.targetLanguage}');

  if (data == null || data.nativeLanguage.isEmpty || data.targetLanguage.isEmpty) {
    debugPrint('⚠️  Missing Firestore data — using fallback nl/tr');
    return const UserLangPrefs(displayName: '', nativeLang: 'tr', targetLang: 'nl', dailyMinutes: 10);
  }

  final prefs = UserLangPrefs(
    displayName: data.displayName,
    nativeLang: data.nativeLanguage,
    targetLang: data.targetLanguage,
    dailyMinutes: data.dailyMinutes,
  );
  debugPrint('✅ Prefs from Firestore: $prefs');
  setCachedUserLangPrefs(prefs);
  
  if (prefs.nativeLang.isNotEmpty) {
    Future.microtask(() {
      ref.read(localeProvider.notifier).state = Locale(prefs.nativeLang);
    });
  }
  
  return prefs;
});

// ── Synchronous cache ─────────────────────────────────────────────────────────

UserLangPrefs _cachedPrefs = const UserLangPrefs(displayName: '', nativeLang: 'tr', targetLang: 'nl', dailyMinutes: 10);

UserLangPrefs get cachedUserLangPrefs => _cachedPrefs;

void setCachedUserLangPrefs(UserLangPrefs prefs) {
  _cachedPrefs = prefs;
}
