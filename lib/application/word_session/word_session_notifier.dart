import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/application/stats/user_stats_provider.dart';
import 'package:kelima/data/datasources/mock_words.dart';
import 'package:kelima/data/models/word_model.dart';
import 'package:kelima/data/models/user_stats_model.dart';

// ── Rating enum ───────────────────────────────────────────────────────────────

enum SrsRating { easy, hard, forgot }

// ── State ─────────────────────────────────────────────────────────────────────

class WordSessionState {
  final List<WordModel> words;
  final int currentIndex;
  final List<SrsRating?> ratings; // null = not yet rated
  final bool isComplete;
  final String nativeLang;
  final String targetLang;

  const WordSessionState({
    required this.words,
    required this.currentIndex,
    required this.ratings,
    this.isComplete = false,
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
    String? nativeLang,
    String? targetLang,
  }) =>
      WordSessionState(
        words: words ?? this.words,
        currentIndex: currentIndex ?? this.currentIndex,
        ratings: ratings ?? this.ratings,
        isComplete: isComplete ?? this.isComplete,
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
          words: _pickWords(_getWordCount(_ref)),
          currentIndex: 0,
          ratings: List.filled(_getWordCount(_ref), null),
          nativeLang: _ref.read(userLangPrefsProvider).valueOrNull?.nativeLang ?? 'tr',
          targetLang: _ref.read(userLangPrefsProvider).valueOrNull?.targetLang ?? 'nl',
        ));

  static int _getWordCount(Ref ref) {
    final prefs = ref.read(userLangPrefsProvider).valueOrNull;
    return prefs != null ? wordsPerSession(prefs.dailyMinutes) : wordsPerSession(10);
  }

  static List<WordModel> _pickWords(int count) {
    final all = List<WordModel>.from(mockWords);
    all.shuffle();
    return all.take(count).toList();
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

    if (state.isLastWord) {
      state = state.copyWith(words: newWords, ratings: newRatings, isComplete: true);
      await _statsService.completeSession();
    } else {
      state = state.copyWith(words: newWords, ratings: newRatings, currentIndex: idx + 1);
    }
  }

  void restart() {
    final count = _getWordCount(_ref);
    state = WordSessionState(
      words: _pickWords(count),
      currentIndex: 0,
      ratings: List.filled(count, null),
      nativeLang: state.nativeLang,
      targetLang: state.targetLang,
    );
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
// IMPORTANT: autoDispose so it rebuilds when userLangPrefsProvider resolves.
// When the FutureProvider completes with Firestore data, Riverpod invalidates
// this provider and creates a fresh WordSessionNotifier with the real prefs.

final wordSessionProvider =
    StateNotifierProvider.autoDispose<WordSessionNotifier, WordSessionState>(
  (ref) {
    // Keep alive so navigation between tabs doesn't reset the session
    ref.keepAlive();

    // Watch so this provider rebuilds when prefs finish loading from Firestore
    final prefsAsync = ref.watch(userLangPrefsProvider);

    prefsAsync.when(
      data: (p) {
        debugPrint('✅ Prefs loaded from Firestore: target=${p.targetLang}, native=${p.nativeLang}');
        setCachedUserLangPrefs(p); // update cache
        return p;
      },
      loading: () {
        debugPrint('⏳ Prefs still loading, using cache: target=${cachedUserLangPrefs.targetLang}');
        return cachedUserLangPrefs;
      },
      error: (e, st) {
        debugPrint('❌ Prefs error: $e — using cache');
        return cachedUserLangPrefs;
      },
    );

    final statsService = ref.read(userStatsServiceProvider);
    return WordSessionNotifier(ref, statsService);
  },
);
