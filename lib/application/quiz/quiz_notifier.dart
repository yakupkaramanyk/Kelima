import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/stats/user_stats_provider.dart';
import 'package:kelima/application/word_session/word_session_notifier.dart';
import 'package:kelima/data/datasources/mock_words.dart';
import 'package:kelima/data/models/word_model.dart';

// ── Quiz type ─────────────────────────────────────────────────────────────────

enum QuizType { photo, writing, multipleChoice }

// ── Question model ────────────────────────────────────────────────────────────

class QuizQuestion {
  final WordModel word;
  final QuizType type;
  final List<WordModel> options; // 4 for photo/MC, empty for writing
  final int correctIndex;

  const QuizQuestion({
    required this.word,
    required this.type,
    required this.options,
    required this.correctIndex,
  });
}

// ── State ─────────────────────────────────────────────────────────────────────

class QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final List<bool?> results;
  final bool showingFeedback;
  final int? selectedIndex; // tapped option index (photo / MC)
  final bool isComplete;

  const QuizState({
    required this.questions,
    required this.currentIndex,
    required this.results,
    this.showingFeedback = false,
    this.selectedIndex,
    this.isComplete = false,
  });

  QuizQuestion get current => questions[currentIndex];
  int get score => results.where((r) => r == true).length;
  bool get isLastQuestion => currentIndex == questions.length - 1;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    List<bool?>? results,
    bool? showingFeedback,
    int? selectedIndex,
    bool clearSelected = false,
    bool? isComplete,
  }) =>
      QuizState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        results: results ?? this.results,
        showingFeedback: showingFeedback ?? this.showingFeedback,
        selectedIndex: clearSelected ? null : selectedIndex ?? this.selectedIndex,
        isComplete: isComplete ?? this.isComplete,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class QuizNotifier extends StateNotifier<QuizState> {
  final UserStatsService _statsService;

  QuizNotifier(List<WordModel> words, this._statsService)
      : super(QuizState(
          questions: _buildQuestions(words),
          currentIndex: 0,
          results: List.filled(5, null),
        ));

  // Record answer and show feedback
  void answer(bool isCorrect, {int? selectedIndex}) {
    final newResults = List<bool?>.from(state.results)
      ..[state.currentIndex] = isCorrect;
    state = state.copyWith(
      results: newResults,
      showingFeedback: true,
      selectedIndex: selectedIndex,
    );
  }

  // Advance to next question (or mark complete)
  void advance() {
    if (state.isLastQuestion) {
      state = state.copyWith(isComplete: true, showingFeedback: false,
          clearSelected: true);
      _statsService.completeSession();
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        showingFeedback: false,
        clearSelected: true,
      );
    }
  }

  // ── Question builder ────────────────────────────────────────────────────────

  static final _rng = Random();

  static List<QuizQuestion> _buildQuestions(List<WordModel> sessionWords) {
    const typeOrder = [
      QuizType.photo,
      QuizType.writing,
      QuizType.multipleChoice,
      QuizType.photo,
      QuizType.writing,
    ];
    return List.generate(
      sessionWords.length,
      (i) => _build(sessionWords[i], typeOrder[i % typeOrder.length]),
    );
  }

  static QuizQuestion _build(WordModel word, QuizType preferred) {
    // Wrong-answer pool: all mock words except the target
    final pool = mockWords.where((w) => w.id != word.id).toList()
      ..shuffle(_rng);

    // Fallback: photo → MC if word has no image
    var type = preferred;
    if (type == QuizType.photo && word.imageUrl == null) {
      type = QuizType.multipleChoice;
    }

    if (type == QuizType.writing) {
      return QuizQuestion(
          word: word, type: type, options: [], correctIndex: 0);
    }

    // 3 wrong options (prefer those with images for photo tests)
    List<WordModel> wrongs;
    if (type == QuizType.photo) {
      final withImg = pool.where((w) => w.imageUrl != null).toList();
      final withoutImg = pool.where((w) => w.imageUrl == null).toList();
      wrongs = [...withImg, ...withoutImg].take(3).toList();
    } else {
      wrongs = pool.take(3).toList();
    }

    final opts = [word, ...wrongs]..shuffle(_rng);
    return QuizQuestion(
      word: word,
      type: type,
      options: opts,
      correctIndex: opts.indexOf(word),
    );
  }
}

// ── Levenshtein helper (for writing test) ─────────────────────────────────────

bool isCloseEnough(String input, String target) {
  final a = input.toLowerCase().trim();
  final b = target.toLowerCase().trim();
  if (a == b) return true;
  if (a.isEmpty || b.isEmpty) return false;
  // Short words (≤4 chars) must match exactly — no typo tolerance
  final maxAllowed = b.length <= 4 ? 0 : 1;
  if (maxAllowed == 0) return false;
  final d = List.generate(
      a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (var i = 0; i <= a.length; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= b.length; j++) {
    d[0][j] = j;
  }
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      d[i][j] = [d[i-1][j]+1, d[i][j-1]+1, d[i-1][j-1]+cost].reduce(min);
    }
  }
  return d[a.length][b.length] <= maxAllowed;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final quizProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizState>((ref) {
  final words = ref.read(wordSessionProvider).words;
  final statsService = ref.read(userStatsServiceProvider);
  return QuizNotifier(words, statsService);
});
