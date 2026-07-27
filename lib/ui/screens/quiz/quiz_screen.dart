import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kelima/application/quiz/quiz_notifier.dart';
import 'package:kelima/application/word_session/word_session_notifier.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';

import 'package:kelima/data/models/word_model.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reset text field when question advances
    ref.listen(quizProvider.select((s) => s.currentIndex), (_, __) {
      _textCtrl.clear();
    });

    final state = ref.watch(quizProvider);
    final session = ref.watch(wordSessionProvider);
    final s = AppLocalizations.of(context)!;
    final targetLang = session.targetLang;
    final nativeLang = session.nativeLang;

    if (state.isComplete) return _ResultsView(state: state, targetLang: targetLang, nativeLang: nativeLang, s: s);

    final q = state.current;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _QuizHeader(
                  index: state.currentIndex,
                  total: state.questions.length,
                  type: q.type,
                  onClose: () => context.go('/home'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: switch (q.type) {
                      QuizType.photo => _PhotoQuestion(
                          state: state,
                          targetLang: targetLang,
                          tapLabel: s.tapCorrectPhoto,
                          seeResultsLabel: s.seeResults,
                          nextLabel: s.next,
                          onAnswer: (idx) {
                            final correct = idx == q.correctIndex;
                            ref.read(quizProvider.notifier).answer(correct, selectedIndex: idx);
                          },
                          onNext: () => ref.read(quizProvider.notifier).advance(),
                        ),
                      QuizType.writing => _WritingQuestion(
                          state: state,
                          targetLang: targetLang,
                          nativeLang: nativeLang,
                          controller: _textCtrl,
                          hintLabel: s.typeWordHint,
                          checkLabel: s.check,
                          correctLabel: s.correctFeedback,
                          incorrectLabel: s.incorrectFeedback,
                          correctAnswerFn: s.correctAnswer,
                          seeResultsLabel: s.seeResults,
                          nextLabel: s.next,
                          onCheck: (input) {
                            final correct = isCloseEnough(input, q.word.wordIn(targetLang));
                            ref.read(quizProvider.notifier).answer(correct);
                          },
                          onNext: () => ref.read(quizProvider.notifier).advance(),
                        ),
                      QuizType.multipleChoice => _MultiChoiceQuestion(
                          state: state,
                          targetLang: targetLang,
                          nativeLang: nativeLang,
                          selectLabel: s.selectCorrectTranslation,
                          seeResultsLabel: s.seeResults,
                          nextLabel: s.next,
                          onAnswer: (idx) {
                            final correct = idx == q.correctIndex;
                            ref.read(quizProvider.notifier).answer(correct, selectedIndex: idx);
                          },
                          onNext: () => ref.read(quizProvider.notifier).advance(),
                        ),
                    },
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

// ── Header ────────────────────────────────────────────────────────────────────

class _QuizHeader extends StatelessWidget {
  final int index;
  final int total;
  final QuizType type;
  final VoidCallback onClose;

  const _QuizHeader(
      {required this.index,
      required this.total,
      required this.type,
      required this.onClose});

  String _typeLabel(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    switch (type) {
      case QuizType.photo:
        return s.photoMatch;
      case QuizType.writing:
        return s.writeIt;
      case QuizType.multipleChoice:
        return s.multipleChoice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_typeLabel(context),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        Text('${index + 1} / $total',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: (index + 1) / total,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Photo question ─────────────────────────────────────────────────────────────

class _PhotoQuestion extends StatelessWidget {
  final QuizState state;
  final String targetLang;
  final String tapLabel;
  final String seeResultsLabel;
  final String nextLabel;
  final void Function(int) onAnswer;
  final VoidCallback onNext;

  const _PhotoQuestion({
    required this.state,
    required this.targetLang,
    required this.tapLabel,
    required this.seeResultsLabel,
    required this.nextLabel,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    return Column(
      children: [
        const SizedBox(height: 8),
        // Word prompt
        Text(
          q.word.wordIn(targetLang),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(tapLabel,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        // 2×2 grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(q.options.length, (i) {
            final opt = q.options[i];
            final isSelected = state.selectedIndex == i;
            final isCorrect = i == q.correctIndex;
            Color? borderColor;
            Widget? badge;
            if (state.showingFeedback) {
              if (isCorrect) {
                borderColor = const Color(0xFF52C8A4);
                badge = const _FeedbackBadge(correct: true);
              } else if (isSelected && !isCorrect) {
                borderColor = const Color(0xFFE05C6D);
                badge = const _FeedbackBadge(correct: false);
              }
            }
            return GestureDetector(
              onTap: state.showingFeedback ? null : () => onAnswer(i),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor ?? AppColors.border,
                        width: borderColor != null ? 3 : 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _DynamicImage(word: opt),
                    ),
                  ),
                  if (badge != null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: badge),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        if (state.showingFeedback) _NextButton(onTap: onNext, isLast: state.isLastQuestion, seeResultsLabel: seeResultsLabel, nextLabel: nextLabel),
      ],
    );
  }
}

// ── Writing question ──────────────────────────────────────────────────────────

class _WritingQuestion extends StatelessWidget {
  final QuizState state;
  final String targetLang;
  final String nativeLang;
  final TextEditingController controller;
  final String hintLabel;
  final String checkLabel;
  final String correctLabel;
  final String incorrectLabel;
  final String Function(String) correctAnswerFn;
  final String seeResultsLabel;
  final String nextLabel;
  final void Function(String) onCheck;
  final VoidCallback onNext;

  const _WritingQuestion({
    required this.state,
    required this.targetLang,
    required this.nativeLang,
    required this.controller,
    required this.hintLabel,
    required this.checkLabel,
    required this.correctLabel,
    required this.incorrectLabel,
    required this.correctAnswerFn,
    required this.seeResultsLabel,
    required this.nextLabel,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    final answered = state.showingFeedback;
    final correct = state.results[state.currentIndex];

    return Column(
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: _DynamicImage(word: q.word, height: 180),
          ),
        ),
        const SizedBox(height: 20),
        Text(AppLocalizations.of(context)!.howDoYouSay,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text(
          '"${q.word.translationIn(nativeLang)}"',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.inLanguage(targetLang.toUpperCase()),
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          enabled: !answered,
          autofocus: false,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            hintText: hintLabel,
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: answered ? null : onCheck,
        ),
        const SizedBox(height: 14),
        if (!answered)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => onCheck(controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(checkLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        if (answered) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: correct == true
                  ? const Color(0xFFEEFBF7)
                  : const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: correct == true
                    ? const Color(0xFF52C8A4)
                    : const Color(0xFFE05C6D),
              ),
            ),
            child: correct == true
                ? Row(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(correctLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF52C8A4),
                              fontSize: 15)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text('❌', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(incorrectLabel,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE05C6D),
                                fontSize: 15)),
                      ]),
                      const SizedBox(height: 6),
                      Text(correctAnswerFn(q.word.wordIn(targetLang)),
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
          ),
          _NextButton(onTap: onNext, isLast: state.isLastQuestion, seeResultsLabel: seeResultsLabel, nextLabel: nextLabel),
        ],
      ],
    );
  }
}

// ── Multiple choice question ───────────────────────────────────────────────────

class _MultiChoiceQuestion extends StatelessWidget {
  final QuizState state;
  final String targetLang;
  final String nativeLang;
  final String selectLabel;
  final String seeResultsLabel;
  final String nextLabel;
  final void Function(int) onAnswer;
  final VoidCallback onNext;

  const _MultiChoiceQuestion({
    required this.state,
    required this.targetLang,
    required this.nativeLang,
    required this.selectLabel,
    required this.seeResultsLabel,
    required this.nextLabel,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          q.word.wordIn(targetLang),
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(selectLabel,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        ...List.generate(q.options.length, (i) {
          final opt = q.options[i];
          final isSelected = state.selectedIndex == i;
          final isCorrect = i == q.correctIndex;
          Color bgColor = AppColors.cardBg;
          Color borderColor = AppColors.border;
          Color textColor = AppColors.textPrimary;
          if (state.showingFeedback) {
            if (isCorrect) {
              bgColor = const Color(0xFFEEFBF7);
              borderColor = const Color(0xFF52C8A4);
              textColor = const Color(0xFF2BAE99);
            } else if (isSelected) {
              bgColor = const Color(0xFFFFF0F2);
              borderColor = const Color(0xFFE05C6D);
              textColor = const Color(0xFFE05C6D);
            }
          }
          return GestureDetector(
            onTap: state.showingFeedback ? null : () => onAnswer(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(opt.translationIn(nativeLang),
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                  ),
                  if (state.showingFeedback && isCorrect)
                    const Text('✅', style: TextStyle(fontSize: 18)),
                  if (state.showingFeedback && isSelected && !isCorrect)
                    const Text('❌', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          );
        }),
        if (state.showingFeedback)
          _NextButton(onTap: onNext, isLast: state.isLastQuestion, seeResultsLabel: seeResultsLabel, nextLabel: nextLabel),
      ],
    );
  }
}

// ── Results view ──────────────────────────────────────────────────────────────

class _ResultsView extends ConsumerWidget {
  final QuizState state;
  final String targetLang;
  final String nativeLang;
  final AppLocalizations s;
  const _ResultsView({required this.state, required this.targetLang, required this.nativeLang, required this.s});

  String get _emoji {
    final s = state.score;
    if (s == 5) return '🏆';
    if (s >= 4) return '🌟';
    if (s >= 3) return '👍';
    return '💪';
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(_emoji,
                      style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  Text(
                    '${state.score} / ${state.questions.length}',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(s.quizMessage(state.score.toString()),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 28),
                  // Question breakdown
                  ...List.generate(state.questions.length, (i) {
                    final q = state.questions[i];
                    final ok = state.results[i] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text(ok ? '✅' : '❌',
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q.word.wordIn(targetLang),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textPrimary)),
                                Text(q.word.translationIn(nativeLang),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          _TypeBadge(type: q.type),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: Text(s.backToHome),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLast;
  final String seeResultsLabel;
  final String nextLabel;
  const _NextButton({
    required this.onTap,
    required this.isLast,
    required this.seeResultsLabel,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isLast ? seeResultsLabel : nextLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(width: 6),
              Icon(
                  isLast
                      ? Icons.bar_chart_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackBadge extends StatelessWidget {
  final bool correct;
  const _FeedbackBadge({required this.correct});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: correct
            ? const Color(0xFF52C8A4)
            : const Color(0xFFE05C6D),
        shape: BoxShape.circle,
      ),
      child: Icon(
        correct ? Icons.check_rounded : Icons.close_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final QuizType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      QuizType.photo => '📸',
      QuizType.writing => '✍️',
      QuizType.multipleChoice => '🔤',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final WordModel word;
  final double height;
  const _PhotoPlaceholder({required this.word, this.height = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F2F1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
        ),
      ),
      child: Center(
        child: Text(
          word.wordIn('en').substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

// ── Dynamic Image Resolver ───────────────────────────────────────────────────

class _DynamicImage extends StatelessWidget {
  final WordModel word;
  final double height;
  const _DynamicImage({required this.word, this.height = double.infinity});

  @override
  Widget build(BuildContext context) {
    if (word.imageUrl == null) {
      return _PhotoPlaceholder(word: word, height: height);
    }
    return Image.network(
      word.imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      loadingBuilder: (ctx, child, prog) => prog == null
          ? child
          : _PhotoPlaceholder(word: word, height: height),
      errorBuilder: (_, __, ___) =>
          _PhotoPlaceholder(word: word, height: height),
    );
  }
}
