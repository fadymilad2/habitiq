import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_toggle.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/google_auth_button.dart';

/// Glassmorphism card that contains the entire authentication form.
///
/// Owns no state — all mutable data is passed in via constructor parameters.
/// This keeps [AuthView] focused on orchestration while [AuthFormCard]
/// is solely responsible for rendering the form UI.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.formKey,
    required this.isLogin,
    required this.isLoading,
    required this.fadeAnimation,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.onSubmit,
    required this.onToggle,
    required this.onGoogleSignIn,
    required this.onForgotPassword,
  });

  // ── Form state ────────────────────────────────────────────────────────────
  final GlobalKey<FormState> formKey;
  final bool isLogin;
  final bool isLoading;
  final Animation<double> fadeAnimation;

  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  final VoidCallback onSubmit;
  final VoidCallback onToggle;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onForgotPassword;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x261A1635),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name (sign-up only) ──────────────────────────────────
                  if (!isLogin) ...[
                    _FieldLabel('FULL NAME'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'John Doe',
                      prefixIcon: Icons.person_outline_rounded,
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      validator: AppValidators.name,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Email ────────────────────────────────────────────────
                  _FieldLabel('EMAIL'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'user@example.com',
                    prefixIcon: Icons.email_outlined,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: 16),

                  // ── Password row (label + Forgot link) ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FieldLabel('PASSWORD'),
                      if (isLogin)
                        GestureDetector(
                          onTap: onForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: passwordController,
                    obscureText: true,
                    textInputAction: isLogin
                        ? TextInputAction.done
                        : TextInputAction.next,
                    validator: AppValidators.password,
                  ),

                  // ── Confirm password (sign-up only) ──────────────────────
                  if (!isLogin) ...[
                    const SizedBox(height: 16),
                    _FieldLabel('CONFIRM PASSWORD'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: confirmController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: AppValidators.confirmPassword(
                        passwordController,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Primary CTA ──────────────────────────────────────────
                  AuthButton(
                    label: isLogin ? 'Login' : 'Create Account',
                    onPressed: onSubmit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 12),

                  // ── OR divider ───────────────────────────────────────────
                  const AuthDivider(),
                  const SizedBox(height: 20),

                  // ── Google sign-in ───────────────────────────────────────
                  GoogleAuthButton(onPressed: onGoogleSignIn),
                  const SizedBox(height: 20),

                  // ── Mode toggle ──────────────────────────────────────────
                  AuthToggle(isLogin: isLogin, onToggle: onToggle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private helper widget ─────────────────────────────────────────────────────

/// Small all-caps field label. Private to this file since it is only
/// used inside [AuthFormCard].
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}
