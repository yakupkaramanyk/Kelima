import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/ui/widgets/primary_button.dart';
import 'package:kelima/ui/widgets/selection_card.dart';
import 'package:kelima/ui/widgets/step_header.dart';


class Step3Goal extends ConsumerWidget {
  const Step3Goal({super.key});

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
          emoji: '🎯',
          title: s.onbGoalTitle,
          subtitle: s.onbGoalSubtitle,
        ),
        const SizedBox(height: 16),

        // ── Goal cards ────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: AppConstants.learningGoals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final goal = AppConstants.learningGoals[index];
              String localizedLabel;
              String localizedDesc;
              switch (goal.code) {
                case 'work': localizedLabel = s.goalWork; localizedDesc = s.goalDescWork; break;
                case 'education': localizedLabel = s.goalEducation; localizedDesc = s.goalDescEducation; break;
                case 'personal': localizedLabel = s.goalPersonal; localizedDesc = s.goalDescPersonal; break;
                case 'visa_exam': localizedLabel = s.goalVisaExam; localizedDesc = s.goalDescVisaExam; break;
                case 'travel':
                default: localizedLabel = s.goalTravel; localizedDesc = s.goalDescTravel; break;
              }
              return SelectionCard(
                emoji: goal.emoji,
                label: localizedLabel,
                sublabel: localizedDesc,
                isSelected: state.learningGoal == goal.code,
                onTap: () => notifier.selectGoal(goal.code),
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
            onPressed: state.learningGoal != null
                ? () => notifier.nextStep()
                : null,
          ),
        ),
      ],
    );
  }
}

