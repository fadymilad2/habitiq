import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/auth/domain/repositories/user_repository.dart';
import 'package:habit_iq/features/profile/data/models/user_model.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_state.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// UserCubit
///
/// Single source of truth for the current user session.
/// Depends on [UserRepository] — never on Hive directly, keeping it testable.
///
/// Provide at the app root (or just above any widget that needs it):
/// ```dart
/// BlocProvider<UserCubit>(
///   create: (_) => UserCubit(UserRepositoryImpl())..checkAuthStatus(),
/// )
/// ```
/// ─────────────────────────────────────────────────────────────────────────────
class UserCubit extends Cubit<UserState> {
  UserCubit(this._repo) : super(const UserInitial());

  final UserRepository _repo;

  // ── Auth check ─────────────────────────────────────────────────────────────

  /// Called once on app start to restore a previous session from Hive.
  ///
  /// Emits [UserAuthenticated] if a user record exists, otherwise
  /// [UserUnauthenticated].
  void checkAuthStatus() {
    emit(const UserLoading());
    final user = _repo.getCurrentUser();
    if (user != null) {
      emit(UserAuthenticated(user));
    } else {
      emit(const UserUnauthenticated());
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Creates a hard-coded demo user and saves them to Hive.
  ///
  /// Use this to bypass real auth during development / demo flows.
  /// Replace with a real auth flow (Google Sign-In, email+password, etc.) later.
  Future<void> loginDummyUser() async {
    emit(const UserLoading());
    try {
      final dummyUser = UserModel(
        id: 'usr_fady_001',
        name: 'Fady Milad',
        level: 1,
        xp: 0,
        streakCount: 0,
        createdAt: DateTime.now(),
      );
      await _repo.saveUser(dummyUser);
      emit(UserAuthenticated(dummyUser));
    } catch (e) {
      // On unexpected errors fall back to unauthenticated so the UI stays safe.
      emit(const UserUnauthenticated());
    }
  }

  // ── Profile update ─────────────────────────────────────────────────────────

  /// Updates one or more fields of the currently authenticated user.
  ///
  /// Silently does nothing if called when no user is authenticated.
  /// Pass only the fields you want to change — omitted ones are preserved.
  Future<void> updateProfile({String? newName, String? newAvatarPath}) async {
    // Guard — can only update if currently authenticated.
    final current = state;
    if (current is! UserAuthenticated) return;

    emit(const UserLoading());
    try {
      final updated = UserModel(
        id: current.user.id,
        name: newName ?? current.user.name,
        avatarPath: newAvatarPath ?? current.user.avatarPath,
        level: current.user.level,
        xp: current.user.xp,
        streakCount: current.user.streakCount,
        createdAt: current.user.createdAt,
      );
      await _repo.updateUser(updated);
      emit(UserAuthenticated(updated));
    } catch (e) {
      // Restore the previous state so the UI doesn't get stuck on a loader.
      emit(current);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  /// Clears the Hive session and emits [UserUnauthenticated].
  Future<void> logout() async {
    emit(const UserLoading());
    await _repo.clearUser();
    emit(const UserUnauthenticated());
  }
}
