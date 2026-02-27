import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Habit name text field with a glowing sparkle suffix icon and helper text.
class HabitNameField extends StatelessWidget {
  const HabitNameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Text field ─────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Name your habit...',
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              // Glowing sparkle suffix
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Helper text ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Example: Read 10 pages of sci-fi',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
