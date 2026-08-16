import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/application/word_session/word_session_notifier.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/data/models/word_model.dart';
import 'package:kelima/ui/widgets/word_flip_card.dart';

class WordSessionScreen extends ConsumerStatefulWidget {
  const WordSessionScreen({super.key});

  @override
  ConsumerState<WordSessionScreen> createState() => _WordSessionScreenState();
}

class _WordSessionScreenState extends ConsumerState<WordSessionScreen> {
  bool _isFlipped = false;

  void _handleFlip() => setState(() => _isFlipped = !_isFlipped);

  void _handleRate(SrsRating rating) {
    ref.read(wordSessionProvider.notifier).rate(rating);
    setState(() => _isFlipped = false);
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(userLangPrefsProvider);
    final session = ref.watch(wordSessionProvider);
    final s = AppLocalizations.of(context)!;

    // Debug: log what language codes the session is using
    debugPrint('🃏 SessionScreen build: targetLang=${session.targetLang}, nativeLang=${session.nativeLang}');
    debugPrint('🃏 PrefsAsync state: ${prefsAsync.runtimeType} / ${prefsAsync.valueOrNull}');

    // If prefs are still loading (Firestore not yet queried), show a spinner
    // so we don't flash English words before Dutch loads.
    if (prefsAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If the SRS session is still being composed (fetching wordProgress from
    // Firestore), show a spinner. Must come before session.currentWord is
    // accessed because that getter does words[currentIndex] and throws on [].
    if (session.isLoading || session.words.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show summary when complete
    if (session.isComplete) {
      return _SummaryView(session: session, s: s);
    }


    final word = session.currentWord;
    final progress = session.currentIndex + 1;
    final total = session.words.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      // Back
                      GestureDetector(
                        onTap: () => context.go('/home'),
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
                      const SizedBox(width: 16),
                      // Progress bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.wordOf(progress, total),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${((progress / total) * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: progress / total,
                                minHeight: 6,
                                backgroundColor: AppColors.border,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Card ────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Use key so card resets when word changes
                        WordFlipCard(
                          key: ValueKey(word.id),
                          word: word,
                          isFlipped: _isFlipped,
                          onFlipped: _handleFlip,
                          targetLang: session.targetLang,
                          nativeLang: session.nativeLang,
                        ),

                        // ── Rating buttons (visible after flip) ─────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: _isFlipped
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Column(
                                    children: [
                                      Text(
                                        s.howWellDidYouKnow,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      RatingButtons(
                                        onRate: _handleRate,
                                        forgotLabel: s.forgot,
                                        hardLabel: s.hard,
                                        easyLabel: s.easy,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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

// ── Summary ───────────────────────────────────────────────────────────────────

class _SummaryView extends ConsumerWidget {
  final WordSessionState session;
  final AppLocalizations s;
  const _SummaryView({required this.session, required this.s});

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

                  // Trophy
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF9A56)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    s.learned5Words,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.greatWork,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    children: [
                      _StatChip(
                          count: session.easyCount,
                          label: s.easy,
                          color: const Color(0xFF52C8A4)),
                      const SizedBox(width: 10),
                      _StatChip(
                          count: session.hardCount,
                          label: s.hard,
                          color: const Color(0xFFFF9A56)),
                      const SizedBox(width: 10),
                      _StatChip(
                          count: session.forgotCount,
                          label: s.forgot,
                          color: const Color(0xFFE05C6D)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Word list
                  ...List.generate(session.words.length, (i) {
                    final w = session.words[i];
                    final r = session.ratings[i];
                    return _WordResultTile(
                      word: w,
                      rating: r,
                      targetLang: session.targetLang,
                      nativeLang: session.nativeLang,
                    );
                  }),

                  const SizedBox(height: 28),

                  // Buttons
                  // ── Start Quiz (primary) ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/quiz'),
                      icon: const Icon(Icons.quiz_rounded, size: 20),
                      label: Text(s.startQuiz,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52C8A4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(wordSessionProvider.notifier).restart();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(s.newSession, style: const TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F0F0),
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      s.backToHome,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600),
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

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordResultTile extends StatelessWidget {
  final WordModel word;
  final dynamic rating;
  final String targetLang;
  final String nativeLang;
  const _WordResultTile({
    required this.word,
    required this.rating,
    this.targetLang = 'en',
    this.nativeLang = 'tr',
  });

  @override
  Widget build(BuildContext context) {
    final ratingColor = rating == SrsRating.easy
        ? const Color(0xFF52C8A4)
        : rating == SrsRating.hard
            ? const Color(0xFFFF9A56)
            : const Color(0xFFE05C6D);
    final s = AppLocalizations.of(context)!;
    final ratingLabel = rating == SrsRating.easy
        ? s.easy
        : rating == SrsRating.hard
            ? s.hard
            : s.forgot;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: ratingColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.wordIn(targetLang),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary),
                ),
                Text(
                  word.translationIn(nativeLang),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ratingColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              ratingLabel,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ratingColor),
            ),
          ),
        ],
      ),
    );
  }
}
