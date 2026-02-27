import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomFloatingNavBar extends StatelessWidget {
  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barHeight = 68.0;
    const double fabSize = 64.0;
    const double barBottomMargin = 24.0;

    // The total height of this container must accommodate the FAB protruding above the bar.
    // Protrusion is roughly (fabSize - barHeight)/2 if perfectly centered, or more if raised.
    // We will raise the FAB so its center aligns with the top edge of the navigation bar,
    // or just visually centered. Let's perfectly center it on the bar.
    const double protrusion = (fabSize - barHeight) / 2 > 0
        ? (fabSize - barHeight) / 2
        : 16.0;
    final containerHeight =
        barHeight + barBottomMargin + bottomPadding + protrusion + 20;

    return SizedBox(
      height: containerHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Glassmorphism Bar ─────────────────────────────────────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: barBottomMargin + bottomPadding,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavBarIcon(
                        icon: Icons.grid_view_rounded,
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _NavBarIcon(
                        icon: Icons.bar_chart_rounded,
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      // Gap for the center FAB
                      const SizedBox(width: fabSize),
                      _NavBarIcon(
                        icon: Icons.smart_toy_outlined,
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      _NavBarIcon(
                        icon: Icons.person_outline_rounded,
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Overlapping Center FAB ────────────────────────────────────────
          Positioned(
            bottom:
                barBottomMargin +
                bottomPadding +
                (barHeight / 2) -
                (fabSize / 2),
            child: GestureDetector(
              onTap: onFabTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  const _NavBarIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              )
            : const BoxDecoration(color: Colors.transparent),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
