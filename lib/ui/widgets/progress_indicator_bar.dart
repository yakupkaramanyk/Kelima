import 'package:flutter/material.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';

class OnboardingProgressBar extends StatelessWidget {
  /// 1-indexed current step (1..5)
  final int currentStep;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.stepOf(currentStep.toString(), AppConstants.totalOnboardingSteps.toString()),
              style: AppTypography.mono(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${((currentStep / AppConstants.totalOnboardingSteps) * 100).round()}%',
              style: AppTypography.mono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.amberDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress track
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: currentStep / AppConstants.totalOnboardingSteps,
            minHeight: 6,
            backgroundColor: AppColors.brandBorder,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.amber),
          ),
        ),
      ],
    );
  }
}
