import 'package:flutter/material.dart';
import 'package:kelima/core/theme/app_theme.dart';

class SelectionCard extends StatefulWidget {
  final String emoji;
  final String label;
  final String? sublabel;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLargeEmoji;

  const SelectionCard({
    super.key,
    required this.emoji,
    required this.label,
    this.sublabel,
    required this.isSelected,
    required this.onTap,
    this.isLargeEmoji = false,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            constraints: const BoxConstraints(minHeight: 68),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.sageLight
                  : _hovering
                      ? AppColors.paperAlt
                      : AppColors.paper,
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.sage
                    : _hovering
                        ? AppColors.sage.withValues(alpha: 0.35)
                        : AppColors.brandBorder,
                width: widget.isSelected ? 2.0 : 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? AppColors.sage.withValues(alpha: 0.16)
                      : _hovering
                          ? AppColors.sage.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                  blurRadius: widget.isSelected ? 20 : (_hovering ? 14 : 8),
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Emoji / Icon
                  Text(
                    widget.emoji,
                    style: TextStyle(
                        fontSize: widget.isLargeEmoji ? 34 : 28),
                  ),
                  const SizedBox(width: 16),
                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label,
                          style: AppTypography.body(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: widget.isSelected
                                ? AppColors.sageDark
                                : AppColors.ink,
                          ),
                        ),
                        if (widget.sublabel != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.sublabel!,
                            style: AppTypography.body(
                              fontSize: 12,
                              color: AppColors.ink.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Checkmark
                  AnimatedOpacity(
                    opacity: widget.isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.sage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
