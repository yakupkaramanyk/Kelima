import 'package:flutter/material.dart';
import 'package:kelima/core/theme/app_theme.dart';

/// Custom error view for better error handling
class ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool fullScreen;
  
  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Bir Hata Oluştu',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message ?? 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(
              'Tekrar Dene',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: content,
            ),
          ),
        ),
      );
    }

    return Center(child: content);
  }
}

/// Compact error widget for smaller spaces
class CompactErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  
  const CompactErrorView({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, 
            size: 32, 
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            message ?? 'Bir hata oluştu',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Tekrar Dene'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom error widget for Flutter's ErrorWidget.builder
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  
  const CustomErrorWidget({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    // In production, show a friendly error screen
    // In development, show more details
    final isDevelopment = const bool.fromEnvironment('dart.vm.product') == false;
    
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bug_report_rounded,
                      size: 40,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Uygulama Hatası',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isDevelopment
                        ? 'Hata: ${details.exception}'
                        : 'Beklenmeyen bir hata oluştu. Lütfen uygulamayı yeniden başlatın.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isDevelopment) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          details.stack.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
