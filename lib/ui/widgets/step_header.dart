import 'package:flutter/material.dart';
import 'package:kelima/core/theme/app_theme.dart';

class StepHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const StepHeader({
    super.key,
    required this.emoji,
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
          decoration: const BoxDecoration(
            color: AppColors.paperAlt,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.amber,
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
              Text(title, style: AppTypography.display(fontSize: 28, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTypography.body(fontSize: 14, color: AppColors.ink.withValues(alpha: 0.65)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
