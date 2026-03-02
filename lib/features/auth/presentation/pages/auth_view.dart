import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import 'package:habit_iq/features/dashboard/presentation/pages/main_dashboard_view.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_cubit.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_state.dart';
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

  /// Validates the form then delegates to [UserCubit.loginDummyUser].
  /// Navigation is handled reactively by the [BlocListener] in [build].
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Delegate auth to UserCubit — BlocListener will navigate on success.
    await context.read<UserCubit>().loginDummyUser();
  }

  void _onGoogleSignIn() {
    // TODO: trigger Google sign-in use-case
  }

  void _onForgotPassword() {
    // TODO: navigate to forgot-password screen
  }

  void _onGuestTap() {
    // Guest mode: create a dummy session, then BlocListener navigates.
    context.read<UserCubit>().loginDummyUser();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      // Navigate to the dashboard the moment the user is authenticated.
      listenWhen: (_, next) => next is UserAuthenticated,
      listener: (context, _) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, a, b) => const MainDashboardView(),
            transitionsBuilder: (_, animation, b, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Scaffold(
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
                    isLoading: false,
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
      ),
    );
  }
}
