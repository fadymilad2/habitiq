import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_cubit.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_state.dart';
import 'splash_state.dart';

import 'package:habit_iq/core/data/services/hive_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SplashCubit
///
/// Waits for the splash animation then delegates navigation:
///   • First launch           → SplashNavigateToOnboarding (OnboardingView)
///   • [AuthAuthenticated]    → SplashNavigateToHome       (MainDashboardView)
///   • anything else          → SplashNavigateToLogin      (AuthView)
///
/// Uses [AuthCubit] (Firebase) instead of [UserCubit] (Hive) so that
/// deleted or expired Firebase accounts are correctly redirected to login.
/// ─────────────────────────────────────────────────────────────────────────────
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._authCubit) : super(SplashInitial()) {
    _navigate();
  }

  final AuthCubit _authCubit;

  Future<void> _navigate() async {
    emit(SplashLoading());

    // Give the splash animation time to play.
    await Future.delayed(const Duration(milliseconds: 2700));

    // 1. Check if this is the first time the app is launched.
    // If 'first_launch' is null, it means the app was just installed or data was wiped.
    final isFirstLaunch =
        HiveService.settingsBox.get('first_launch', defaultValue: true) as bool;

    if (isFirstLaunch) {
      // We don't set it to false here — that should happen when they actually finish onboarding.
      emit(SplashNavigateToOnboarding());
      return;
    }

    // 2. Not first launch, check Firebase Auth.
    _authCubit.checkAuthStatus();

    // Give checkAuthStatus a tick to emit its state.
    await Future.delayed(const Duration(milliseconds: 100));

    final authState = _authCubit.state;

    if (authState is AuthAuthenticated) {
      emit(SplashNavigateToHome());
    } else {
      // Covers AuthUnauthenticated, AuthInitial, AuthError edge cases.
      emit(SplashNavigateToLogin());
    }
  }
}
