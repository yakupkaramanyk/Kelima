import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/auth/auth_provider.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/application/stats/user_stats_provider.dart';
import 'package:kelima/data/datasources/mock_words.dart';
import 'package:kelima/data/models/word_model.dart';
import 'package:kelima/data/models/user_stats_model.dart';
import 'package:kelima/data/repositories/word_progress_repository.dart';

// ── Rating enum ───────────────────────────────────────────────────────────────

enum SrsRating { easy, hard, forgot }

// ── State ─────────────────────────────────────────────────────────────────────

class WordSessionState {
  final List<WordModel> words;
  final int currentIndex;
  final List<SrsRating?> ratings; // null = not yet rated
  final bool isComplete;
  final bool isLoading;
  final String nativeLang;
  final String targetLang;

  const WordSessionState({
    required this.words,
    required this.currentIndex,
    required this.ratings,
    this.isComplete = false,
    this.isLoading = false,
    this.nativeLang = 'tr',
    this.targetLang = 'nl', // default to Dutch as most likely target
  });

  WordModel get currentWord => words[currentIndex];
  bool get isLastWord => currentIndex == words.length - 1;
  int get easyCount => ratings.where((r) => r == SrsRating.easy).length;
  int get hardCount => ratings.where((r) => r == SrsRating.hard).length;
  int get forgotCount => ratings.where((r) => r == SrsRating.forgot).length;

  WordSessionState copyWith({
    List<WordModel>? words,
    int? currentIndex,
    List<SrsRating?>? ratings,
    bool? isComplete,
    bool? isLoading,
    String? nativeLang,
    String? targetLang,
  }) =>
      WordSessionState(
        words: words ?? this.words,
        currentIndex: currentIndex ?? this.currentIndex,
        ratings: ratings ?? this.ratings,
        isComplete: isComplete ?? this.isComplete,
        isLoading: isLoading ?? this.isLoading,
        nativeLang: nativeLang ?? this.nativeLang,
        targetLang: targetLang ?? this.targetLang,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WordSessionNotifier extends StateNotifier<WordSessionState> {
  final Ref _ref;
  final UserStatsService _statsService;

  WordSessionNotifier(this._ref, this._statsService)
      : super(WordSessionState(
          words: const [],
          currentIndex: 0,
          ratings: const [],
          isLoading: true,
          nativeLang:
              _ref.read(userLangPrefsProvider).valueOrNull?.nativeLang ?? 'tr',
          targetLang:
              _ref.read(userLangPrefsProvider).valueOrNull?.targetLang ?? 'nl',
        )) {
    _loadSession();

    // Keep displayed language in sync when Firestore prefs resolve (or when
    // the user changes target language) — without rebuilding the provider or
    // touching words/currentIndex/ratings.
    _ref.listen<AsyncValue<UserLangPrefs>>(userLangPrefsProvider, (previous, next) {
      final p = next.valueOrNull;
      if (p != null) {
        state = state.copyWith(nativeLang: p.nativeLang, targetLang: p.targetLang);
      }
    });
  }

  static int _getWordCount(Ref ref) {
    final prefs = ref.read(userLangPrefsProvider).valueOrNull;
    return prefs != null ? wordsPerSession(prefs.dailyMinutes) : wordsPerSession(10);
  }

  /// Fallback: random selection from mockWords, same as the old behavior.
  List<WordModel> _randomFallback(int count) {
    final all = List<WordModel>.from(mockWords);
    all.shuffle();
    return all.take(count).toList();
  }

  Future<void> _loadSession() async {
    final uid = _ref.read(currentUserProvider)?.uid;
    final count = _getWordCount(_ref);

    // No authenticated user — fall back to random selection immediately.
    if (uid == null) {
      final words = _randomFallback(count);
      state = state.copyWith(
        words: words,
        currentIndex: 0,
        ratings: List.filled(words.length, null),
        isLoading: false,
      );
      return;
    }

    try {
      String targetLang;
      String nativeLang = state.nativeLang;
      try {
        final prefs = await _ref.read(userLangPrefsProvider.future);
        targetLang = prefs.targetLang;
        nativeLang = prefs.nativeLang;
      } catch (e) {
        targetLang = cachedUserLangPrefs.targetLang;
        nativeLang = cachedUserLangPrefs.nativeLang;
      }

      final progressMap = await _ref
          .read(wordProgressRepositoryProvider)
          .getAllProgress(uid, targetLang);

      final now = DateTime.now();

      // 1. Due words: seen before AND nextReviewDate is in the past.
      //    Sort ascending by nextReviewDate (most overdue first).
      final dueWords = mockWords
          .where((w) =>
              progressMap.containsKey(w.id) &&
              progressMap[w.id]!.nextReviewDate.isBefore(now))
          .map((w) => w.copyWith(srsData: progressMap[w.id]!))
          .toList()
        ..sort((a, b) =>
            a.srsData.nextReviewDate.compareTo(b.srsData.nextReviewDate));

      // 2. New words: never seen before. Keep mockWords' original order so
      //    topic/difficulty progression is respected.
      final newWords = mockWords
          .where((w) => !progressMap.containsKey(w.id))
          .toList();

      // 3. Filler words: seen AND not yet due. Shuffle — order doesn't matter.
      final fillerWords = mockWords
          .where((w) =>
              progressMap.containsKey(w.id) &&
              !progressMap[w.id]!.nextReviewDate.isBefore(now))
          .map((w) => w.copyWith(srsData: progressMap[w.id]!))
          .toList()
        ..shuffle();

      // Compose session: due → new → filler, in priority order.
      final composed = <WordModel>[];
      for (final list in [dueWords, newWords, fillerWords]) {
        for (final word in list) {
          if (composed.length >= count) break;
          composed.add(word);
        }
        if (composed.length >= count) break;
      }

      state = state.copyWith(
        words: composed,
        ratings: List.filled(composed.length, null),
        isLoading: false,
        currentIndex: 0,
        targetLang: targetLang,
        nativeLang: nativeLang,
      );
    } catch (e) {
      // Any error → fall back to random so the user is never stuck on spinner.
      debugPrint('⚠️ _loadSession failed, using random fallback: $e');
      final words = _randomFallback(count);
      state = state.copyWith(
        words: words,
        currentIndex: 0,
        ratings: List.filled(words.length, null),
        isLoading: false,
      );
    }
  }

  void rate(SrsRating rating) async {
    final idx = state.currentIndex;
    final word = state.currentWord;
    final updated = _applyRating(word, rating);

    final newWords = List<WordModel>.from(state.words)..[idx] = updated;
    final newRatings = List<SrsRating?>.from(state.ratings)..[idx] = rating;

    int xpGained = 0;
    if (rating == SrsRating.easy) {
      xpGained = 10;
    } else if (rating == SrsRating.hard) {
      xpGained = 5;
    }

    _statsService.addWordRating(xpGained);

    // Persist SRS progress to Firestore — fire and forget.
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid != null) {
      unawaited(_ref
          .read(wordProgressRepositoryProvider)
          .saveProgress(uid, state.targetLang, word.id, updated.srsData));
    }

    if (state.isLastWord) {
      state = state.copyWith(words: newWords, ratings: newRatings, isComplete: true);
      await _statsService.completeSession();
    } else {
      state = state.copyWith(
          words: newWords, ratings: newRatings, currentIndex: idx + 1);
    }
  }

  void restart() {
    // Reset to loading state and re-run the SRS-aware session builder.
    state = state.copyWith(
      isLoading: true,
      words: [],
      ratings: [],
      isComplete: false,
      currentIndex: 0,
    );
    _loadSession();
  }

  WordModel _applyRating(WordModel word, SrsRating rating) {
    final srs = word.srsData;
    late final int newInterval;
    late final double newEase;

    switch (rating) {
      case SrsRating.easy:
        newEase = srs.easeFactor + 0.1;
        newInterval = (srs.interval * newEase).round().clamp(1, 365);
        break;
      case SrsRating.hard:
        newEase = (srs.easeFactor - 0.15).clamp(1.3, 5.0);
        newInterval = (srs.interval * 1.2).round().clamp(1, 365);
        break;
      case SrsRating.forgot:
        newEase = (srs.easeFactor - 0.3).clamp(1.3, 5.0);
        newInterval = 1;
        break;
    }

    final nextReview = DateTime.now().add(Duration(days: newInterval));
    return word.copyWith(
      srsData: srs.copyWith(
        interval: newInterval,
        easeFactor: newEase,
        nextReviewDate: nextReview,
      ),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
//
// autoDispose so the notifier is GC-ed when the user leaves the session screen
// entirely. keepAlive() inside the factory prevents disposal while the screen
// is alive (even during tab switches).
// Language updates are handled by the _ref.listen() inside the notifier itself,
// so this provider no longer watches userLangPrefsProvider — it will never
// rebuild mid-session due to a prefs change.

final wordSessionProvider =
    StateNotifierProvider.autoDispose<WordSessionNotifier, WordSessionState>(
  (ref) {
    // Keep alive so navigation between tabs doesn't reset the session.
    ref.keepAlive();

    final statsService = ref.read(userStatsServiceProvider);
    return WordSessionNotifier(ref, statsService);
  },
);
