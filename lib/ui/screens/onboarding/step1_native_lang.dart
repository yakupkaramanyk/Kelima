import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/l10n/locale_provider.dart';
import 'package:kelima/ui/widgets/primary_button.dart';
import 'package:kelima/ui/widgets/selection_card.dart';
import 'package:kelima/ui/widgets/step_header.dart';

// ── Localised motivational subtitles shown under each language card ───────────

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

class Step1NativeLang extends ConsumerWidget {
  const Step1NativeLang({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final s        = AppLocalizations.of(context)!;

    // Pick subtitle map based on currently selected language
    final isTr        = ref.watch(localeProvider).languageCode == 'tr';
    final subtitleMap = isTr ? _langSubtitlesTr : _langSubtitlesEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Step header ───────────────────────────────────────────
        StepHeader(
          emoji: '🌍',
          title: s.onbNativeLangTitle,
          subtitle: s.onbNativeLangSubtitle,
        ),
        const SizedBox(height: 16),

        // ── Language cards ────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: AppConstants.languages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lang = AppConstants.languages[index];
              return SelectionCard(
                emoji: lang.flag,
                label: lang.name,
                sublabel: subtitleMap[lang.code],
                isSelected: state.nativeLanguage == lang.code,
                onTap: () {
                  // 1. Update the locale → triggers instant UI rebuild
                  ref.read(localeProvider.notifier).state = Locale(lang.code);
                  // 2. Also tell the onboarding notifier (keeps existing logic)
                  notifier.selectNativeLanguage(lang.code);
                },
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
            onPressed: state.nativeLanguage != null
                ? () => notifier.nextStep()
                : null,
          ),
        ),
      ],
    );
  }
}

