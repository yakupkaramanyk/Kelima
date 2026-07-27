import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/ui/widgets/primary_button.dart';
import 'package:kelima/ui/widgets/selection_card.dart';


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
        // ── Gradient header ───────────────────────────────────────
        _StepHeader(
          emoji: '🎯',
          gradColors: const [Color(0xFFFF9A56), Color(0xFFFF6B35)],
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
