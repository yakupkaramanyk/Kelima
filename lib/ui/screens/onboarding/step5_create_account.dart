import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kelima/application/auth/auth_notifier.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/core/constants/app_constants.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/router/app_router.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/ui/widgets/primary_button.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/application/auth/auth_provider.dart';
import 'package:kelima/data/repositories/user_repository.dart';

class Step5CreateAccount extends ConsumerStatefulWidget {
  const Step5CreateAccount({super.key});

  @override
  ConsumerState<Step5CreateAccount> createState() => _Step5CreateAccountState();
}

class _Step5CreateAccountState extends ConsumerState<Step5CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isRegisterTab = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ob = ref.read(onboardingNotifierProvider);
    
    if (_isRegisterTab) {
      if (!ob.isReadyToSubmit) return;
      final displayName = [
        _firstNameCtrl.text.trim(),
        _lastNameCtrl.text.trim()
      ].where((s) => s.isNotEmpty).join(' ');

      final ok = await ref.read(authNotifierProvider.notifier).createAccountAndSaveOnboarding(
            email: _emailCtrl.text,
            password: _passCtrl.text,
            displayName: displayName,
            onboardingData: ob.toOnboardingData(),
          );
      if (ok && mounted) {
        ref.invalidate(userLangPrefsProvider);
        context.go(AppRoutes.home);
      }
    } else {
      final ok = await ref.read(authNotifierProvider.notifier).signIn(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        onboardingData: ob.isReadyToSubmit ? ob.toOnboardingData() : null,
      );
      if (ok && mounted) {
        final uid = ref.read(currentUserProvider)?.uid;
        if (uid != null && (ob.targetLanguage != null || ob.nativeLanguage != null)) {
          final update = <String, dynamic>{};
          if (ob.nativeLanguage != null) update['nativeLanguage'] = ob.nativeLanguage;
          if (ob.targetLanguage != null) update['targetLanguage'] = ob.targetLanguage;
          if (ob.learningGoal != null) update['learningGoal'] = ob.learningGoal;
          if (ob.dailyMinutes != null) update['dailyMinutes'] = ob.dailyMinutes;
          
          if (update.isNotEmpty) {
            await ref.read(userRepositoryProvider).updatePartialOnboardingData(
              uid: uid,
              data: update,
            );
          }
        }
        ref.invalidate(userLangPrefsProvider);
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final s = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient illustration header
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 36)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isRegisterTab = true),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: _isRegisterTab ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColors.primary,
                                width: _isRegisterTab ? 0 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                s.tabRegister,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _isRegisterTab ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isRegisterTab = false),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: !_isRegisterTab ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColors.primary,
                                width: !_isRegisterTab ? 0 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                s.tabSignIn,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: !_isRegisterTab ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isRegisterTab ? s.onbAccountTitle : s.welcomeBack,
                    style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRegisterTab ? s.onbAccountSubtitle : s.signInSubtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (_isRegisterTab) ...[
                    _OnboardingSummaryChip(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _firstNameCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: s.onbNameHint,
                        prefixIcon: const Icon(Icons.person_outline,
                            color: AppColors.textSecondary, size: 20),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: s.lastNameHint,
                        prefixIcon: const Icon(Icons.person_outline,
                            color: AppColors.textSecondary, size: 20),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: s.emailPlaceholder,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.textSecondary, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return s.validationEnterEmail;
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                        return s.validationValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: s.passwordPlaceholder,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary, size: 20),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary, size: 20,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return s.validationEnterPassword;
                      if (v.length < 6) return s.validationPasswordLength;
                      return null;
                    },
                  ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(auth.errorMessage!,
                            style: const TextStyle(fontSize: 13, color: AppColors.error,
                                fontWeight: FontWeight.w500))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isRegisterTab ? s.onbCreateAccount : s.signIn,
                    suffixIcon: _isRegisterTab ? Icons.rocket_launch_rounded : null,
                    isLoading: auth.isLoading,
                    onPressed: auth.isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary chip ──────────────────────────────────────────────────────────────

class _OnboardingSummaryChip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(onboardingNotifierProvider);
    final nl = AppConstants.languages.where((l) => l.code == s.nativeLanguage).firstOrNull;
    final tl = AppConstants.languages.where((l) => l.code == s.targetLanguage).firstOrNull;
    if (nl == null || tl == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withValues(alpha: 0.08),
          AppColors.accent.withValues(alpha: 0.08),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Text('${nl.flag}  →  ${tl.flag}', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${nl.name} → ${tl.name}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('${s.dailyMinutes} min/day · ${s.learningGoal}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}
