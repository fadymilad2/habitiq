import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// "Continue as Guest →" tappable link displayed below the auth card.
///
/// Requires [onTap] — callback for guest navigation logic.
class AuthGuestOption extends StatelessWidget {
  const AuthGuestOption({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Continue as Guest',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.textSecondary,
            size: 14,
          ),
        ],
      ),
    );
  }
}
