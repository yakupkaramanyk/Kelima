import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/application/word_session/word_session_notifier.dart';
import 'package:kelima/core/theme/app_theme.dart';

import 'package:kelima/core/utils/tts_service.dart';
import 'package:kelima/data/models/word_model.dart';
import 'package:kelima/l10n/app_localizations.dart';
// ── Topic gradient map ────────────────────────────────────────────────────────

const _topicGradients = {
  WordTopic.food: [Color(0xFFFF9A56), Color(0xFFFF6B35)],
  WordTopic.health: [Color(0xFF56CFB2), Color(0xFF2BAE99)],
  WordTopic.work: [Color(0xFF667EEA), Color(0xFF764BA2)],
  WordTopic.travel: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  WordTopic.home: [Color(0xFFF093FB), Color(0xFFF5576C)],
  WordTopic.nature: [Color(0xFF43E97B), Color(0xFF38F9D7)],
  WordTopic.dailyLife: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
};

const _categoryColors = {
  WordCategory.noun: Color(0xFF4A90D9),
  WordCategory.verb: Color(0xFF52C8A4),
  WordCategory.adjective: Color(0xFFFF9A56),
  WordCategory.adverb: Color(0xFF9B59B6),
  WordCategory.phrase: Color(0xFFE05C6D),
};

// ── Main flip card ────────────────────────────────────────────────────────────

class WordFlipCard extends StatefulWidget {
  final WordModel word;
  final VoidCallback onFlipped;
  final bool isFlipped;
  final String targetLang;
  final String nativeLang;

  const WordFlipCard({
    super.key,
    required this.word,
    required this.onFlipped,
    required this.isFlipped,
    this.targetLang = 'en',
    this.nativeLang = 'tr',
  });

  @override
  State<WordFlipCard> createState() => _WordFlipCardState();
}

class _WordFlipCardState extends State<WordFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(WordFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync animation with external isFlipped state
    if (widget.isFlipped && !oldWidget.isFlipped) {
      _ctrl.forward();
    } else if (!widget.isFlipped && oldWidget.isFlipped) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() => widget.onFlipped();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final showFront = _anim.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi * _anim.value),
            child: showFront
                ? _FrontFace(word: widget.word, targetLang: widget.targetLang, nativeLang: widget.nativeLang)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _BackFace(word: widget.word, targetLang: widget.targetLang, nativeLang: widget.nativeLang),
                  ),
          );
        },
      ),
    );
  }
}

// ── Front face ────────────────────────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  final WordModel word;
  final String targetLang;
  final String nativeLang;
  const _FrontFace({required this.word, required this.targetLang, required this.nativeLang});

  @override
  Widget build(BuildContext context) {
    final catColor =
        _categoryColors[word.category] ?? AppColors.primary;
    final gradColors =
        _topicGradients[word.topic] ?? [AppColors.primary, AppColors.accent];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient top bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: catColor,
              borderRadius: const BorderRadius.vertical(

                  top: Radius.circular(24)),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Category badge + TTS button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CategoryBadge(
                        label: word.category.localizedLabel(AppLocalizations.of(context)!), color: catColor),
                    _TtsButton(word: word.wordIn(targetLang), langCode: UserLangPrefs.ttsLocaleFor(targetLang)),
                  ],
                ),
                const SizedBox(height: 40),

                // Main word (target language)
                Text(
                  word.wordIn(targetLang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Topic chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: gradColors[0].withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    word.topic.localizedLabel(AppLocalizations.of(context)!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: gradColors[0],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Tap hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.touch_app_rounded,
                        size: 16, color: Colors.black45),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.tapToSeeTranslation,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Difficulty dots
                _DifficultyDots(difficulty: word.difficulty),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Back face ─────────────────────────────────────────────────────────────────
//
// Now a ConsumerStatefulWidget so it can:
//   1. Attempt to load word.imageUrl (if set).
//   2. On null or network error, call PexelsService.getPhoto(english word)
//      to fetch a real photo dynamically.
//   3. Cache results on the shared PexelsService instance (per session).

class _BackFace extends StatelessWidget {
  final WordModel word;
  final String targetLang;
  final String nativeLang;
  const _BackFace(
      {required this.word,
      required this.targetLang,
      required this.nativeLang});

  @override
  Widget build(BuildContext context) {
    final gradColors =
        _topicGradients[word.topic] ?? [AppColors.primary, AppColors.accent];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Photo area ──────────────────────────────────────────────────────
          Container(
            height: 220,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: word.imageUrl != null
                ? Image.network(
                    word.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _GradientPlaceholder(
                          colors: gradColors, word: word);
                    },
                    errorBuilder: (_, __, ___) {
                      return _GradientPlaceholder(
                          colors: gradColors, word: word);
                    },
                  )
                : _GradientPlaceholder(colors: gradColors, word: word),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Translation (native language)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        word.translationIn(nativeLang),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    _TtsButton(
                        word: word.translationIn(nativeLang),
                        langCode:
                            UserLangPrefs.ttsLocaleFor(nativeLang)),
                  ],
                ),
                const SizedBox(height: 16),

                // Definition split
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAFA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DefinitionPane(
                          flag: UserLangPrefs.flagFor(nativeLang),
                          text: word.definitionIn(nativeLang),
                          isLeft: true,
                        ),
                      ),
                      Container(
                          width: 1, height: 60, color: AppColors.border),
                      Expanded(
                        child: _DefinitionPane(
                          flag: UserLangPrefs.flagFor(targetLang),
                          text: word.definitionIn(targetLang),
                          isLeft: false,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, thickness: 1, height: 24),
                const SizedBox(height: 4),

                // Example sentences
                _ExampleRow(
                  flag: UserLangPrefs.flagFor(nativeLang),
                  text: word.exampleIn(nativeLang),
                ),
                const SizedBox(height: 8),
                _ExampleRow(
                  flag: UserLangPrefs.flagFor(targetLang),
                  text: word.exampleIn(targetLang),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rating buttons ────────────────────────────────────────────────────────────

class RatingButtons extends StatelessWidget {
  final void Function(SrsRating) onRate;
  final String forgotLabel;
  final String hardLabel;
  final String easyLabel;

  const RatingButtons({
    super.key,
    required this.onRate,
    this.forgotLabel = 'Forgot',
    this.hardLabel = 'Hard',
    this.easyLabel = 'Easy',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RatingBtn(
            label: forgotLabel,
            emoji: '😞',
            color: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
            onTap: () => onRate(SrsRating.forgot),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RatingBtn(
            label: hardLabel,
            emoji: '😅',
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
            onTap: () => onRate(SrsRating.hard),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RatingBtn(
            label: easyLabel,
            emoji: '😊',
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
            onTap: () => onRate(SrsRating.easy),
          ),
        ),
      ],
    );
  }
}

class _RatingBtn extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _RatingBtn({
    required this.label,
    required this.emoji,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: [
             BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }
}

class _TtsButton extends ConsumerWidget {
  final String word;
  final String langCode;
  const _TtsButton({required this.word, required this.langCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(ttsServiceProvider).speak(word, langCode),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.volume_up_rounded,
            size: 18, color: Colors.white),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  final int difficulty;
  const _DifficultyDots({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i < difficulty ? 10 : 6,
          height: i < difficulty ? 10 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < difficulty
                ? AppColors.primary
                : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

class _DefinitionPane extends StatelessWidget {
  final String flag;
  final String text;
  final bool isLeft;
  const _DefinitionPane(
      {required this.flag, required this.text, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          isLeft ? 12 : 10, 10, isLeft ? 10 : 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(flag, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  final String flag;
  final String text;
  const _ExampleRow({required this.flag, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(flag, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '"$text"',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  final List<Color> colors;
  final WordModel word;
  const _GradientPlaceholder(
      {required this.colors, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word.translations['en']?.substring(0, 1).toUpperCase() ?? '?',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              word.topic.label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
