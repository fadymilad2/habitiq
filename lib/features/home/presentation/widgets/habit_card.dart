import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/widgets/glow_toggle.dart';
import 'package:habit_iq/features/habit/presentation/pages/habit_details_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../habit/data/models/habit_model.dart';

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
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailsView(habit: habit),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                        IconData(habit.icon, fontFamily: 'MaterialIcons'),
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
                    GlowToggle(
                      value: habit.isCompleted,
                      onChanged: (_) => onToggle(),
                    ),
                  ],
                ),
              ),
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
