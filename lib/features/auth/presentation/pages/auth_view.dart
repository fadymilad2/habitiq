import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_cubit.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_state.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_cubit.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_cubit.dart';
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

    if (_isLogin) {
      context.read<AuthCubit>().loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      context.read<AuthCubit>().registerWithEmail(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _onGoogleSignIn() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _onForgotPassword() {
    // TODO: navigate to forgot-password screen
  }

  void _onGuestTap() {
    context.read<AuthCubit>().signInAsGuest();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        // On any successful login:
        //  - For guest (anonymous): wipe Hive + create a fresh profile.
        //  - For all logins: reload cubits so stale data from a previous
        //    session is replaced with the correct state for this user.
        if (state is AuthAuthenticated) {
          if (state.user.isAnonymous) {
            await context.read<UserCubit>().loginGuestUser(state.user.uid);
          } else {
            // For real accounts: load existing profile from Hive (populated by
            // pullFromCloud) OR create a new one with the user's display name.
            final displayName =
                state.user.displayName ?? state.user.email ?? 'User';
            await context.read<UserCubit>().loginRealUser(
              state.user.uid,
              displayName,
            );
          }
          if (!context.mounted) return;
          context.read<HabitsCubit>().loadTodayHabits();
          context.read<AnalyticsCubit>().loadAnalytics();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainDashboardView()),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: AppBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const AuthHeader(),
                    const SizedBox(height: 36),
                    AuthFormCard(
                      formKey: _formKey,
                      isLogin: _isLogin,
                      isLoading: isLoading,
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
                    AuthGuestOption(onTap: _onGuestTap),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
