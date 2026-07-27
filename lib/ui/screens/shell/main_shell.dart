import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/l10n/app_localizations.dart';
import 'package:kelima/core/theme/app_theme.dart';
import 'package:kelima/ui/screens/home/home_screen.dart';
import 'package:kelima/ui/screens/practice/practice_screen.dart';
import 'package:kelima/ui/screens/progress/progress_screen.dart';

// Persists tab selection across full-screen navigation (session / quiz)
final mainTabIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    HomeScreen(),
    PracticeScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(mainTabIndexProvider);
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: index,
              children: _screens,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.school_outlined,
                      activeIcon: Icons.school_rounded,
                      label: s.navLearn,
                      isActive: index == 0,
                      onTap: () => ref.read(mainTabIndexProvider.notifier).state = 0,
                    ),
                    _NavItem(
                      icon: Icons.fitness_center_outlined,
                      activeIcon: Icons.fitness_center_rounded,
                      label: s.navPractice,
                      isActive: index == 1,
                      onTap: () => ref.read(mainTabIndexProvider.notifier).state = 1,
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart_rounded,
                      label: s.navProgress,
                      isActive: index == 2,
                      onTap: () => ref.read(mainTabIndexProvider.notifier).state = 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom nav item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : const Color(0xFF757575);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 26,
                weight: isActive ? 700 : 600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
