import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/onboarding/onboarding_notifier.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/ui/widgets/primary_button.dart';

class Step2Name extends ConsumerStatefulWidget {
  const Step2Name({super.key});

  @override
  ConsumerState<Step2Name> createState() => _Step2NameState();
}

class _Step2NameState extends ConsumerState<Step2Name> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if user went back
    final existing = ref.read(onboardingNotifierProvider).displayName;
    if (existing != null) _ctrl.text = existing;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      ref.read(onboardingNotifierProvider.notifier).setDisplayName(_ctrl.text);
      ref.read(onboardingNotifierProvider.notifier).nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Gradient header ───────────────────────────────────────
        Container(
          width: double.infinity,
          height: 124,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
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
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👋', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Title ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.onbNameTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.onbNameSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Name input ───────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _continue(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: s.onbNameHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.textSecondary, size: 22),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                  if (v.trim().length < 2) {
                    return 'Name must be at least 2 characters.';
                  }
                  // Only letters (latin + extended unicode for international names)
                  if (!RegExp(r"^[a-zA-ZÀ-ÖØ-öø-ÿ\u0100-\u024F\s\-']+$")
                      .hasMatch(v.trim())) {
                    return 'Please use letters only.';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),

        // ── CTA ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: PrimaryButton(
            label: s.continueBtn,
            suffixIcon: Icons.arrow_forward_rounded,
            onPressed: _continue,
          ),
        ),
      ],
    );
  }
}
