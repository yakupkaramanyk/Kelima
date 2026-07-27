import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kelima/application/auth/auth_provider.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/router/app_router.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/data/repositories/auth_repository.dart';
import 'package:kelima/application/stats/user_stats_provider.dart';
import 'package:kelima/data/models/user_stats_model.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _greeting(AppLocalizations s) {
  final h = DateTime.now().hour;
  if (h < 12) return s.goodMorning;
  if (h < 18) return s.goodAfternoon;
  return s.goodEvening;
}

/// Returns displayName from Firestore if set, otherwise parses the email.
String _resolvedName(String? displayName, String? email, AppLocalizations s) {
  if (displayName != null && displayName.isNotEmpty) return displayName;
  if (email == null || email.isEmpty) return s.defaultLearnerName;
  final local = email.split('@').first;
  if (local.isEmpty) return s.defaultLearnerName;
  return local[0].toUpperCase() + local.substring(1);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final langAsync = ref.watch(userLangPrefsProvider);
    final s = AppLocalizations.of(context)!;
    final targetLang = langAsync.valueOrNull?.targetLang ?? 'nl';
    final displayName = langAsync.valueOrNull?.displayName;
    final dailyMinutes = langAsync.valueOrNull?.dailyMinutes ?? 10;
    final name = _resolvedName(displayName, user?.email, s);
    String getLocalizedLangName(String code) {
      switch (code) {
        case 'en': return s.lang_en;
        case 'tr': return s.lang_tr;
        case 'nl': return s.lang_nl;
        case 'de': return s.lang_de;
        case 'fr': return s.lang_fr;
        default: return code;
      }
    }
    final langName = getLocalizedLangName(targetLang);
    final langFlag = UserLangPrefs.flagFor(targetLang);

    final statsAsync = ref.watch(userStatsProvider);
    final stats = statsAsync.value ?? UserStatsModel.empty();

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Gradient header ──────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90D9), Color(0xFF38C9AC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo row + avatar
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.auto_stories_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text('kelima',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.4)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showProfileSheet(context, ref),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.5),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Greeting
                      Text(_greeting(s),
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 4),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1)),
                      const SizedBox(height: 12),
                      // Target language chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(langFlag,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(s.learningLang(langName),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Streak card
                      _StreakCard(s: s, stats: stats),
                      const SizedBox(height: 14),

                      // Progress card
                      _ProgressCard(s: s, stats: stats),
                      const SizedBox(height: 24),

                      // Section title
                      Text(s.todaySession,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 12),

                      // Start Learning — gradient full-width button
                      _StartLearningBtn(
                          label: s.startLearning,
                          subLabel: s.startLearningSub(wordsPerSession(dailyMinutes)),
                          onTap: () => context.go(AppRoutes.session)),
                      const SizedBox(height: 12),

                      // Locked feature cards
                      _LockedCard(
                        icon: Icons.quiz_rounded,
                        emoji: '🧠',
                        label: s.practiceQuiz,
                        sub: s.practiceQuizSub,
                        color: const Color(0xFF667EEA),
                      ),
                      const SizedBox(height: 10),
                      _LockedCard(
                        icon: Icons.forum_rounded,
                        emoji: '🤖',
                        label: s.aiConversation,
                        sub: s.aiConversationSub,
                        color: const Color(0xFFFF9A56),
                      ),
                    ],
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

// ── Streak card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final AppLocalizations s;
  final UserStatsModel stats;
  const _StreakCard({required this.s, required this.stats});

  @override
  Widget build(BuildContext context) {
    final streakDays = stats.streakCount;
    final now = DateTime.now();
    // weekday: 1=Mon .. 7=Sun
    final todayIdx = now.weekday - 1; // 0-based, 0=Mon
    final labels = s.weekdays.split(',');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90D9), Color(0xFF2E6FB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.dailyStreak,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  Text('🔥 ${s.dayStreak(streakDays)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 7-day circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isActive = i == todayIdx; // only today for streak=1
              return Column(
                children: [
                  Text(labels[i],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.white
                          : Colors.transparent,
                      border: isActive
                          ? null
                          : Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Center(
                      child: isActive
                          ? const Text('🔥',
                              style: TextStyle(fontSize: 20))
                          : const SizedBox(),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(s.keepLearning,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Progress card ─────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final AppLocalizations s;
  final UserStatsModel stats;
  const _ProgressCard({required this.s, required this.stats});

  @override
  Widget build(BuildContext context) {
    final wordsToday = stats.todayWordsLearned;
    final wordsGoal = stats.todayGoal > 0 ? stats.todayGoal : 5;
    final displayedWords = wordsToday.clamp(0, wordsGoal);
    final progress = displayedWords / wordsGoal;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.todayProgress,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(s.wordsOf(displayedWords, wordsGoal),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(s.startFirstSession,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Start Learning button ─────────────────────────────────────────────────────

class _StartLearningBtn extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final String subLabel;
  const _StartLearningBtn({
    required this.onTap,
    this.label = 'Start Learning',
    this.subLabel = '5 new words ready · Tap to begin',
  });

  @override
  State<_StartLearningBtn> createState() => _StartLearningBtnState();
}

class _StartLearningBtnState extends State<_StartLearningBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 34)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 3),
                    Text(widget.subLabel,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Locked feature card ───────────────────────────────────────────────────────

class _LockedCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String label;
  final String sub;
  final Color color;

  const _LockedCard({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded,
                size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Profile sheet ─────────────────────────────────────────────────────────────

void _showProfileSheet(BuildContext context, WidgetRef ref) {
  final user = ref.read(currentUserProvider);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProfileSheet(email: user?.email ?? ''),
  );
}

class _ProfileSheet extends ConsumerWidget {
  final String email;
  const _ProfileSheet({required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded,
                    size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)?.signedInAs ?? 'Signed in as',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              context.push('/settings');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)?.settings ?? 'Settings',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go(AppRoutes.onboarding);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)?.signOut ?? 'Sign Out',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
