import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom "Don't have an account? Sign Up" / "Already have an account? Log In"
/// toggle link inside the auth glassmorphism card.
///
/// Requires:
/// - [isLogin] — current auth mode to derive the correct label text.
/// - [onToggle] — callback invoked when the user taps the link.
class AuthToggle extends StatelessWidget {
  const AuthToggle({super.key, required this.isLogin, required this.onToggle});

  final bool isLogin;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final prompt = isLogin
        ? "Don't have an account? "
        : 'Already have an account? ';
    final action = isLogin ? 'Sign Up' : 'Log In';

    return Center(
      child: GestureDetector(
        onTap: onToggle,
        child: RichText(
          text: TextSpan(
            text: prompt,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: action,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
