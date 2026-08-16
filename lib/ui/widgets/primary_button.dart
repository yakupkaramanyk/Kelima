import 'package:flutter/material.dart';
import 'package:kelima/core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? suffixIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              onPressed == null && !isLoading ? AppColors.brandBorder : AppColors.ink,
          disabledBackgroundColor: AppColors.brandBorder,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.ink.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.body(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(suffixIcon, size: 18, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}
