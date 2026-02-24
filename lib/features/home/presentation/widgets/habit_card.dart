import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/habit_model.dart';

/// A dark glassmorphism card representing a single habit in the list.
///
/// Parameters:
/// - [habit]       — the [HabitModel] to render.
/// - [onToggle]    — called when the user taps the completion toggle.
class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.habit, required this.onToggle});

  final HabitModel habit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: habit.isAIPick
              ? AppColors.primary.withValues(alpha: 0.55)
              : AppColors.surfaceHighlight,
          width: 1,
        ),
        boxShadow: habit.isCompleted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Main content row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: habit.isCompleted
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    habit.icon,
                    color: habit.isCompleted
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        habit.subtitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: habit.isAIPick
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle
                _GlowToggle(isCompleted: habit.isCompleted, onTap: onToggle),
              ],
            ),
          ),

          // ── AI PICK badge ────────────────────────────────────────────────
          if (habit.isAIPick)
            Positioned(
              top: -1,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI PICK',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Private toggle widget ─────────────────────────────────────────────────────

/// A custom animated on/off toggle with a neon glow when active.
class _GlowToggle extends StatelessWidget {
  const _GlowToggle({required this.isCompleted, required this.onTap});

  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isCompleted ? AppColors.primary : AppColors.surfaceHighlight,
          boxShadow: isCompleted
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
              left: isCompleted ? 24 : 2,
              top: 3,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: isCompleted
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
