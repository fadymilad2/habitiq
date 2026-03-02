import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/features/auth/domain/repositories/user_repository.dart';
import 'package:habit_iq/features/profile/data/models/user_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Hive-backed implementation of [UserRepository].
///
/// Storage strategy:
///   • The app supports a single local user session.
///   • The user is stored under the fixed key [_kUserKey] inside `userBox`.
///   • All mutations (save / update / clear) are synchronous at the Hive level
///     but exposed as `Future`s so the interface stays infrastructure-agnostic
///     (easy to swap to a remote API later).
/// ─────────────────────────────────────────────────────────────────────────────
class UserRepositoryImpl implements UserRepository {
  /// Fixed Hive key under which the single local user session is stored.
  static const String _kUserKey = 'current_user';

  /// Typed reference to the Hive box opened by [HiveService].
  Box<UserModel> get _box => HiveService.userBox;

  // ── Read ───────────────────────────────────────────────────────────────────

  @override
  UserModel? getCurrentUser() {
    // Returns null if no user has been saved yet (first launch / after logout).
    return _box.get(_kUserKey);
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  @override
  Future<void> saveUser(UserModel user) async {
    // Hive's put is synchronous on-device; await keeps the interface clean.
    await _box.put(_kUserKey, user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    // Functionally identical to saveUser — we overwrite by the same key.
    // Having a named method makes intent crystal-clear at the call site.
    await _box.put(_kUserKey, user);
  }

  @override
  Future<void> clearUser() async {
    await _box.delete(_kUserKey);
  }
}
