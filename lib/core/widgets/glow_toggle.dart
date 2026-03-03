import 'package:flutter/material.dart';
import 'package:habit_iq/core/theme/app_colors.dart';

/// A custom animated on/off toggle with a neon glow when active.
class GlowToggle extends StatelessWidget {
  const GlowToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? AppColors.primary : AppColors.surfaceHighlight,
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: value ? 24 : 2,
              top: 3,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: value
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 14,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
