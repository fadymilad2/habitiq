import 'package:habit_iq/features/profile/data/models/user_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Abstract contract for all user persistence operations.
///
/// The cubit layer depends on THIS interface — never on the concrete impl.
/// This keeps the cubit testable and decoupled from Hive.
/// ─────────────────────────────────────────────────────────────────────────────
abstract class UserRepository {
  /// Returns the currently stored [UserModel], or `null` if no user is saved.
  UserModel? getCurrentUser();

  /// Persists a brand-new [user] to local storage.
  Future<void> saveUser(UserModel user);

  /// Overwrites an existing user entry with updated data from [user].
  Future<void> updateUser(UserModel user);

  /// Removes the user from local storage (used on logout).
  Future<void> clearUser();
}
