import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Habit name text field with a functional AI sparkle suffix button.
///
/// - [isLoading] true  → shows a small [CircularProgressIndicator] instead of ✨
/// - [isLoading] false → shows ✨ [IconButton] that fires [onSuggestTap]
/// - [errorMessage] non-null → shows inline error text below the field
class HabitNameField extends StatelessWidget {
  const HabitNameField({
    super.key,
    required this.controller,
    this.onSuggestTap,
    this.isLoading = false,
    this.errorMessage,
  });

  final TextEditingController controller;
  final VoidCallback? onSuggestTap;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Glowing text field container ───────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLoading
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.primary.withValues(alpha: 0.22),
              width: isLoading ? 1.5 : 1,
            ),
            boxShadow: isLoading
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
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
              // ── Sparkle / spinner suffix ──────────────────────────────
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: onSuggestTap,
                        tooltip: 'AI Suggest',
                        icon: ShaderMask(
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
        ),

        // ── Helper / error text ─────────────────────────────────────────────
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: errorMessage != null
                ? Text(
                    errorMessage!,
                    key: const ValueKey('error'),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  )
                : Text(
                    isLoading
                        ? 'AI is crafting a habit for you...'
                        : 'Tap ✨ to get an AI suggestion',
                    key: ValueKey(isLoading),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
