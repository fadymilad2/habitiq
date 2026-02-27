import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Top navigation row for the New Habit modal screen.
///
/// - "Cancel" TextButton on the left (pops the route).
/// - "New Habit" bold title centred.
/// - Trailing [SizedBox] mirrors the Cancel width for perfect centering.
class NewHabitHeader extends StatelessWidget {
  const NewHabitHeader({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Cancel
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            minimumSize: const Size(60, 36),
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Title — centred by Expanded on both sides
        Expanded(
          child: Text(
            'New Habit',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Mirror spacer so the title stays centred
        const SizedBox(width: 60),
      ],
    );
  }
}
