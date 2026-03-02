import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_cubit.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_state.dart';
import 'splash_state.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SplashCubit
///
/// Waits for the splash animation then delegates navigation to [UserCubit]:
///   • [UserAuthenticated]     → SplashNavigateToHome  (MainDashboardView)
///   • anything else           → SplashNavigateToLogin (AuthView)
///
/// [UserCubit] must be provided above this widget in the tree (done in main.dart
/// via MultiBlocProvider).
/// ─────────────────────────────────────────────────────────────────────────────
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._userCubit) : super(SplashInitial()) {
    _navigate();
  }

  final UserCubit _userCubit;

  Future<void> _navigate() async {
    emit(SplashLoading());

    // Give the splash animation time to play.
    await Future.delayed(const Duration(milliseconds: 2700));

    // Read the auth state that UserCubit already resolved on app start.
    final authState = _userCubit.state;

    if (authState is UserAuthenticated) {
      emit(SplashNavigateToHome());
    } else {
      // Covers UserUnauthenticated, UserInitial, UserLoading edge cases.
      emit(SplashNavigateToLogin());
    }
  }
}
