import 'package:equatable/equatable.dart';
import 'package:habit_iq/features/profile/data/models/user_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Sealed state hierarchy for [UserCubit].
///
/// Flow:
///   UserInitial  (app cold-start)
///       │
///       ├──[user found in Hive]──► UserAuthenticated
///       │
///       └──[no user in Hive]─────► UserUnauthenticated
///
///   UserAuthenticated ──[logout]──► UserUnauthenticated
///   UserUnauthenticated ──[loginDummy]──► UserAuthenticated
/// ─────────────────────────────────────────────────────────────────────────────
sealed class UserState extends Equatable {
  const UserState();
}

/// App has just launched; auth check has not yet started.
final class UserInitial extends UserState {
  const UserInitial();
  @override
  List<Object?> get props => [];
}

/// Auth check or save is in progress (shows a loading indicator if needed).
final class UserLoading extends UserState {
  const UserLoading();
  @override
  List<Object?> get props => [];
}

/// A valid [user] session is active.
final class UserAuthenticated extends UserState {
  const UserAuthenticated(this.user);
  final UserModel user;

  @override
  List<Object?> get props => [
    user.id,
    user.name,
    user.avatarPath,
    user.level,
    user.xp,
  ];
}

/// No user is saved in Hive — show auth / onboarding screens.
final class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
  @override
  List<Object?> get props => [];
}
