import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// The "Your Habits" title row with a "VIEW ALL" action link.
///
/// Extracted from [HomeView] to keep the page file as a pure orchestrator.
/// Pass [onViewAll] to handle navigation to the full habit list.
class HabitsSectionHeader extends StatelessWidget {
  const HabitsSectionHeader({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Section title ─────────────────────────────────────────────────
        Text(
          'Your Habits',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        // ── "VIEW ALL" link ───────────────────────────────────────────────
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'VIEW ALL',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
