import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/application/stats/user_stats_provider.dart';
import 'package:kelima/data/models/user_stats_model.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/data/datasources/mock_words.dart';
import 'package:kelima/data/models/word_model.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(userStatsProvider);
    final stats = statsAsync.value ?? UserStatsModel.empty();

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.progressTitle,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(s.keepLearning,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 24),

                _LevelCard(s: s, stats: stats),
                const SizedBox(height: 14),

                _StreakCard(s: s, stats: stats),
                const SizedBox(height: 14),

                _VocabCard(s: s),
                const SizedBox(height: 14),

                _TopicsCard(s: s),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared card wrapper ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final String emoji;
  final Widget child;
  const _Card(
      {required this.title, required this.emoji, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Level & XP card ───────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final AppLocalizations s;
  final UserStatsModel stats;
  const _LevelCard({required this.s, required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalXp = stats.totalXP;
    // Each level takes 100 XP
    final level = (totalXp ~/ 100) + 1;
    final currentLevelXp = totalXp % 100;
    const nextLevelXpTarget = 100;
    final progress = (currentLevelXp / nextLevelXpTarget).clamp(0.0, 1.0);
    final xpNeeded = nextLevelXpTarget - currentLevelXp;

    return _Card(
      emoji: '⭐',
      title: s.levelAndXp,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF2E6FB5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  s.levelLabel(level),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$currentLevelXp XP',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        const Text('$nextLevelXpTarget XP',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        s.xpToNextLevel(xpNeeded, level + 1),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    final currentStreak = stats.streakCount;
    final today = DateTime.now().weekday;
    final activeDays = <int>{};
    for (var i = 0; i < currentStreak; i++) {
      activeDays.add(((today - 1 - i) % 7 + 7) % 7);
    }

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final wordsLearnedToday = stats.todayWordsLearned;

    return _Card(
      emoji: '🔥',
      title: s.streakLabel,
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              _StreakStat(
                  value: '$currentStreak',
                  label: s.currentStreakLabel,
                  color: const Color(0xFFFF9A56)),
              const _Divider(),
              _StreakStat(
                  value: '$currentStreak',
                  label: s.longestStreakLabel,
                  color: AppColors.primary),
              const _Divider(),
              _StreakStat(
                  value: '$wordsLearnedToday',
                  label: s.wordsThisWeek,
                  color: const Color(0xFF52C8A4)),
            ],
          ),
          const SizedBox(height: 20),
          // Weekly calendar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isActive = activeDays.contains(i);
              final isToday = i == (today - 1) % 7;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFFFF9A56)
                          : AppColors.surface,
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFFFF9A56)
                            : isActive
                                ? const Color(0xFFFF9A56)
                                : AppColors.border,
                        width: isToday ? 2 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: isActive
                          ? const Text('🔥',
                              style: TextStyle(fontSize: 16))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dayLabels[i],
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isToday
                              ? const Color(0xFFFF9A56)
                              : AppColors.textSecondary)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StreakStat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}

// ── Vocabulary card ───────────────────────────────────────────────────────────

class _VocabCard extends StatelessWidget {
  final AppLocalizations s;
  const _VocabCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final total = mockWords.length;
    final nouns = mockWords
        .where((w) => w.category == WordCategory.noun)
        .length;
    final verbs = mockWords
        .where((w) => w.category == WordCategory.verb)
        .length;
    final adjectives = mockWords
        .where((w) => w.category == WordCategory.adjective)
        .length;
    final other = mockWords
        .where((w) =>
            w.category == WordCategory.adverb ||
            w.category == WordCategory.phrase)
        .length;

    return _Card(
      emoji: '📚',
      title: s.vocabularyLabel,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$total',
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -2)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(s.wordsInLibrary,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CategoryRow(
              label: s.nouns,
              count: nouns,
              total: total,
              color: AppColors.primary),
          const SizedBox(height: 10),
          _CategoryRow(
              label: s.verbs,
              count: verbs,
              total: total,
              color: const Color(0xFF52C8A4)),
          const SizedBox(height: 10),
          _CategoryRow(
              label: s.adjectives,
              count: adjectives,
              total: total,
              color: const Color(0xFFFF9A56)),
          const SizedBox(height: 10),
          _CategoryRow(
              label: s.other,
              count: other,
              total: total,
              color: const Color(0xFF667EEA)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _CategoryRow(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text('$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ),
      ],
    );
  }
}

// ── Topics card ───────────────────────────────────────────────────────────────

class _TopicsCard extends StatelessWidget {
  final AppLocalizations s;
  const _TopicsCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final total = mockWords.length;

    final topicMeta = {
      WordTopic.food: ('🍎', s.topicFood),
      WordTopic.dailyLife: ('☀️', s.topicDailyLife),
      WordTopic.home: ('🏠', s.topicHome),
      WordTopic.travel: ('✈️', s.topicTravel),
      WordTopic.nature: ('🌿', s.topicNature),
      WordTopic.health: ('🏥', s.topicHealth),
      WordTopic.work: ('💼', s.topicWork),
    };

    final rows = WordTopic.values.map((topic) {
      final count = mockWords.where((w) => w.topic == topic).length;
      final meta = topicMeta[topic] ?? ('📌', topic.name);
      return _TopicRow(
          emoji: meta.$1,
          label: meta.$2,
          count: count,
          total: total);
    }).toList();

    return _Card(
      emoji: '📌',
      title: s.topicsLabel,
      child: Column(
        children: rows
            .expand((r) => [r, const SizedBox(height: 12)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final int total;
  const _TopicRow(
      {required this.emoji,
      required this.label,
      required this.count,
      required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            Text('$count / $total',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: count / total,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accent),
          ),
        ),
      ],
    );
  }
}
