import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/ui/widgets/primary_button.dart';
import 'package:kelima/ui/widgets/selection_card.dart';

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
        // ── Gradient header ───────────────────────────────────────
        _StepHeader(
          emoji: '⏰',
          gradColors: const [Color(0xFF43E97B), Color(0xFF38D9A9)],
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
