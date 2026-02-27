import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import 'package:habit_iq/features/dashboard/presentation/pages/main_dashboard_view.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_guest_option.dart';
import '../widgets/auth_header.dart';

/// The main Authentication screen.
///
/// Responsibility: **orchestration only**.
/// - Owns the form [GlobalKey], [TextEditingController]s, and animation.
/// - Delegates all UI rendering to [AuthHeader], [AuthFormCard],
///   and [AuthGuestOption].
/// - Delegates all validation logic to [AppValidators] (via [AuthFormCard]).
class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView>
    with SingleTickerProviderStateMixin {
  // ── Mode ──────────────────────────────────────────────────────────────────
  bool _isLogin = true;
  bool _isLoading = false;

  // ── Form keys & controllers ───────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Fades the card out, flips the mode, then fades back in.
  void _toggleMode() {
    _animCtrl.reverse().then((_) {
      setState(() => _isLogin = !_isLogin);
      _animCtrl.forward();
    });
  }

  /// Validates the form then runs the auth action.
  /// Replace the [Future.delayed] stub with a real BLoC / use-case call.
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    // ── Placeholder: simulate a 2-second network call ─────────────────────
    await Future.delayed(const Duration(seconds: 2));
    // TODO: replace ↑ with: await context.read<AuthCubit>().login(email, pass);

    if (!mounted) return;
    setState(() => _isLoading = false);

    // ── Navigate to Home, removing the entire auth back-stack ─────────────
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainDashboardView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onGoogleSignIn() {
    // TODO: trigger Google sign-in use-case
  }

  void _onForgotPassword() {
    // TODO: navigate to forgot-password screen
  }

  void _onGuestTap() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainDashboardView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ── Header: logo + title + tagline ────────────────────────
                const AuthHeader(),

                const SizedBox(height: 36),

                // ── Glassmorphism form card ────────────────────────────────
                AuthFormCard(
                  formKey: _formKey,
                  isLogin: _isLogin,
                  isLoading: _isLoading,
                  fadeAnimation: _fadeAnim,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmController: _confirmController,
                  onSubmit: _submit,
                  onToggle: _toggleMode,
                  onGoogleSignIn: _onGoogleSignIn,
                  onForgotPassword: _onForgotPassword,
                ),

                const SizedBox(height: 20),

                // ── Guest option ──────────────────────────────────────────
                AuthGuestOption(onTap: _onGuestTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
