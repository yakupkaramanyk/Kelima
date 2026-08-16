import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/ui/widgets/primary_button.dart';
import 'package:kelima/ui/widgets/selection_card.dart';
import 'package:kelima/ui/widgets/step_header.dart';

// We use dynamic string building in the UI to combine these instead of hardcoding

class Step4Time extends ConsumerWidget {
  const Step4Time({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final s = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Step header ───────────────────────────────────────────
        StepHeader(
          emoji: '⏰',
          title: s.onbTimeTitle,
          subtitle: s.onbTimeSubtitle,
        ),
        const SizedBox(height: 16),

        // ── Time cards ────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: AppConstants.studyTimes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = AppConstants.studyTimes[index];
              String localizedDesc;
              int wordCount;
              switch (option.minutes) {
                case 5: localizedDesc = s.timeDesc5; wordCount = 3; break;
                case 10: localizedDesc = s.timeDesc10; wordCount = 7; break;
                case 15: localizedDesc = s.timeDesc15; wordCount = 10; break;
                case 30: localizedDesc = '${s.timeDesc30} 🚀'; wordCount = 20; break;
                default: localizedDesc = s.timeDesc10; wordCount = 7; break;
              }
              // For simplicity, just combining them
              final wordsPerDay = '${s.wordsPerDay(wordCount.toString())} · $localizedDesc';
              
              return SelectionCard(
                emoji: '⏱️',
                label: option.label,
                sublabel: wordsPerDay,
                isSelected: state.dailyMinutes == option.minutes,
                onTap: () => notifier.selectDailyMinutes(option.minutes),
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
            onPressed: state.dailyMinutes != null
                ? () => notifier.nextStep()
                : null,
          ),
        ),
      ],
    );
  }
}

