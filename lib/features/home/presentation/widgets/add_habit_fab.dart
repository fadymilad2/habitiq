import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A large, prominently glowing '+' FAB that sits centred above
/// the [FloatingNavBar], overlapping it significantly.
///
/// Size: 68 × 68 px with a two-layer neon glow for maximum visual pop.
class AddHabitFab extends StatelessWidget {
  const AddHabitFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            // Outer wide glow
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.50),
              blurRadius: 32,
              spreadRadius: 6,
              offset: Offset.zero,
            ),
            // Inner tight glow for that "lit from within" look
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.75),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
