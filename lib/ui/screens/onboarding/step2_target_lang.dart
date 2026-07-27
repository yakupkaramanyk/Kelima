import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/l10n/locale_provider.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/ui/widgets/primary_button.dart';
import 'package:kelima/ui/widgets/selection_card.dart';

const _langSubtitlesEn = {
  'tr': 'Spoken by 80 M+ people worldwide',
  'en': "The world's global language",
  'nl': 'Gateway to the Netherlands & Belgium',
  'de': 'Language of science & innovation',
  'fr': 'Language of culture & diplomacy',
};

const _langSubtitlesTr = {
  'tr': 'Dünya genelinde 80 milyondan fazla konuşucu',
  'en': 'Dünyanın ortak dili',
  'nl': 'Hollanda ve Belçika\'ya açılan kapı',
  'de': 'Bilim ve inovasyonun dili',
  'fr': 'Kültür ve diplomasi dili',
};

class Step2TargetLang extends ConsumerWidget {
  const Step2TargetLang({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final s = AppLocalizations.of(context)!;
    final isTr = ref.watch(localeProvider).languageCode == 'tr';
    final subtitleMap = isTr ? _langSubtitlesTr : _langSubtitlesEn;

    final available = AppConstants.languages
        .where((l) => l.code != state.nativeLanguage)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Gradient header ───────────────────────────────────────
        _StepHeader(
          emoji: '🚀',
          gradColors: const [Color(0xFF4FACFE), Color(0xFF00C6FF)],
          title: s.onbTargetTitle,
          subtitle: s.onbTargetSubtitle,
        ),
        const SizedBox(height: 16),

        // ── Language cards ────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: available.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lang = available[index];
              return SelectionCard(
                emoji: lang.flag,
                label: lang.name,
                sublabel: subtitleMap[lang.code],
                isSelected: state.targetLanguage == lang.code,
                onTap: () => notifier.selectTargetLanguage(lang.code),
                isLargeEmoji: true,
              );
            },
          ),
        ),

        // ── CTA ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: PrimaryButton(
            label: s.continueBtn,
            suffixIcon: Icons.arrow_forward_rounded,
            onPressed: state.targetLanguage != null
                ? () => notifier.nextStep()
                : null,
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String emoji;
  final List<Color> gradColors;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.emoji,
    required this.gradColors,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 124,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
