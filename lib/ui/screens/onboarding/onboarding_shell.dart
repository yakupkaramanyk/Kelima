import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/ui/screens/onboarding/step1_native_lang.dart';
import 'package:kelima/ui/screens/onboarding/step2_target_lang.dart';
import 'package:kelima/ui/screens/onboarding/step3_goal.dart';
import 'package:kelima/ui/screens/onboarding/step4_time.dart';
import 'package:kelima/ui/screens/onboarding/step5_create_account.dart';
import 'package:kelima/ui/widgets/bracket_mark.dart';
import 'package:kelima/ui/widgets/progress_indicator_bar.dart';

class OnboardingShell extends ConsumerWidget {
  const OnboardingShell({super.key});

  static const List<Widget> _steps = [
    Step1NativeLang(),
    Step2TargetLang(),
    Step3Goal(),
    Step4Time(),
    Step5CreateAccount(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final currentStep = state.currentStep;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    children: [
                      // Back button row
                      Row(
                        children: [
                          if (currentStep > 0)
                            _BackButton(
                              label: s.backBtn,
                              onTap: () => notifier.previousStep(),
                            )
                          else
                            const SizedBox(height: 36),
                          const Spacer(),
                          // Kelima logo/wordmark
                          Row(
                            children: [
                              const BracketMark(size: 26, color: AppColors.ink),
                              const SizedBox(width: 8),
                              Text('kelima', style: AppTypography.display(fontSize: 20, color: AppColors.ink)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Progress bar
                      OnboardingProgressBar(currentStep: currentStep + 1),
                    ],
                  ),
                ),

                // ── Step Content (fade transition) ────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(currentStep),
                      child: _steps[currentStep],
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

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _BackButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.brandBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: AppColors.ink.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


