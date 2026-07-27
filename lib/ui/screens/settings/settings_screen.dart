import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kelima/application/auth/auth_provider.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/data/repositories/user_repository.dart';
import 'package:kelima/ui/screens/onboarding/step2_target_lang.dart';
import 'package:kelima/ui/screens/onboarding/step3_goal.dart';
import 'package:kelima/ui/screens/onboarding/step4_time.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/data/models/user_stats_model.dart';

// ── Main Settings Screen ──────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userLangPrefsProvider);
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)?.settings ?? 'Settings',
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: prefsAsync.when(
        data: (prefs) {
          final lang = AppConstants.languages
              .where((l) => l.code == prefs.targetLang)
              .firstOrNull;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Text(
                    s.learnTarget,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(lang?.flag ?? '🏳️', style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Text(
                              lang?.name ?? prefs.targetLang,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final uid = ref.read(currentUserProvider)?.uid;
                              if (uid != null) {
                                final data = await ref
                                    .read(userRepositoryProvider)
                                    .getOnboardingData(uid);
                                if (data != null && context.mounted) {
                                  final notifier = ref.read(onboardingNotifierProvider.notifier);
                                  notifier.reset();
                                  notifier.setDisplayName(data.displayName);
                                  notifier.selectNativeLanguage(data.nativeLanguage);
                                  notifier.selectTargetLanguage(data.targetLanguage);
                                  notifier.selectGoal(data.learningGoal);
                                  notifier.selectDailyMinutes(data.dailyMinutes);
                                  notifier.goToStep(2);
                                  context.push('/settings_flow');
                                }
                              }
                            },
                            child: Text(
                              s.changeLanguage,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    s.dailyTime,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('⏱️', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Text(
                              s.minutesSuffix(prefs.dailyMinutes),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _showTimeSelectionSheet(context, ref, prefs.dailyMinutes);
                            },
                            child: Text(
                              s.changeTime,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(s.errorLoadingSettings)),
      ),
    );
  }

  void _showTimeSelectionSheet(BuildContext context, WidgetRef ref, int currentMinutes) {
    final s = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.dailyTime,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...AppConstants.studyTimes.map((option) {
                  final isSelected = option.minutes == currentMinutes;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (isSelected) return;
                        
                        final uid = ref.read(currentUserProvider)?.uid;
                        if (uid != null) {
                          await ref.read(userRepositoryProvider).updatePartialOnboardingData(
                                uid: uid,
                                data: {
                                  'dailyMinutes': option.minutes,
                                  'todayGoal': wordsPerSession(option.minutes),
                                },
                              );
                          ref.refresh(userLangPrefsProvider.future);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.cardBg,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              s.minutesSuffix(option.minutes),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Settings Flow Shell ───────────────────────────────────────────────────────

class SettingsFlowShell extends ConsumerStatefulWidget {
  const SettingsFlowShell({super.key});

  @override
  ConsumerState<SettingsFlowShell> createState() => _SettingsFlowShellState();
}

class _SettingsFlowShellState extends ConsumerState<SettingsFlowShell> {
  static const List<Widget> _steps = [
    Step2TargetLang(),
    Step3Goal(),
    Step4Time(),
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Listen for step 5 completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        onboardingNotifierProvider.select((state) => state.currentStep),
        (previous, next) async {
          if (next == 5 && !_isSaving) {
            _saveAndExit();
          }
        },
      );
    });
  }

  Future<void> _saveAndExit() async {
    setState(() => _isSaving = true);
    final ob = ref.read(onboardingNotifierProvider);
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid != null) {
      final update = <String, dynamic>{};
      if (ob.nativeLanguage != null) update['nativeLanguage'] = ob.nativeLanguage;
      if (ob.targetLanguage != null) update['targetLanguage'] = ob.targetLanguage;
      if (ob.learningGoal != null) update['learningGoal'] = ob.learningGoal;
      if (ob.dailyMinutes != null) update['dailyMinutes'] = ob.dailyMinutes;
      if (ob.displayName != null && ob.displayName!.isNotEmpty) update['displayName'] = ob.displayName;

      if (update.isNotEmpty) {
        await ref.read(userRepositoryProvider).updatePartialOnboardingData(
              uid: uid,
              data: update,
            );
      }
      await ref.refresh(userLangPrefsProvider.future);
      if (mounted) {
        context.pop();
      }
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final s = AppLocalizations.of(context)!;
    
    // We only show steps 2, 3, 4 (which correspond to index 0, 1, 2 in our local list)
    final stepIndex = state.currentStep - 2;
    
    // If it somehow goes out of bounds, show loading or empty
    if (stepIndex < 0 || stepIndex > 2) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (state.currentStep > 2) {
                            notifier.previousStep();
                          } else {
                            context.pop();
                          }
                        },
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.border, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                s.backBtn,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: KeyedSubtree(
                      key: ValueKey<int>(state.currentStep),
                      child: _isSaving
                          ? const Center(child: CircularProgressIndicator())
                          : _steps[stepIndex],
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
