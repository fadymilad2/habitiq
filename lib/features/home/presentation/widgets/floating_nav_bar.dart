import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A floating glassmorphism bottom navigation bar with 4 items.
///
/// All four icons are evenly distributed across the full bar width.
/// The [AddHabitFab] is overlaid externally (in [HomeView]) and sits centred
/// on top of this bar — this widget does NOT reserve a gap for it.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  static const _items = [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Home'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Stats'),
    _NavItem(icon: Icons.smart_toy_outlined, label: 'AI'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            // All 4 icons evenly spaced — FAB sits on top via external Stack
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _items.length,
                (i) => _NavBarIcon(
                  item: _items[i],
                  isSelected: selectedIndex == i,
                  onTap: () => onItemTap(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ── Icon tile ─────────────────────────────────────────────────────────────────

class _NavBarIcon extends StatelessWidget {
  const _NavBarIcon({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Icon(
          item.icon,
          size: 24,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
