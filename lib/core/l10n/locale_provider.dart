import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden');
});

/// The active locale of the app.
final localeProvider = StateProvider<Locale>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final saved = prefs.getString('selected_locale');
  
  // ignore: deprecated_member_use
  ref.listenSelf((previous, next) {
    if (next != previous) {
      prefs.setString('selected_locale', next.languageCode);
    }
  });

  return Locale(saved ?? 'en');
});
