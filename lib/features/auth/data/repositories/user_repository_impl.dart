import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/features/auth/domain/repositories/user_repository.dart';
import 'package:habit_iq/features/profile/data/models/user_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Hive-backed implementation of [UserRepository].
///
/// Storage strategy:
///   • Each user is keyed by their actual userId (Firebase UID or guest UID).
///   • This ensures per-account isolation — switching accounts never leaks
///     XP, level, or profile data from a previous session.
///   • The currently active userId is stored in [settingsBox] under
///     [_kActiveUserIdKey] so [getCurrentUser] can find it after a restart.
/// ─────────────────────────────────────────────────────────────────────────────
class UserRepositoryImpl implements UserRepository {
  /// Settings box key that tracks which userId is currently active.
  static const String _kActiveUserIdKey = 'active_user_id';

  Box<UserModel> get _box => HiveService.userBox;
  Box<dynamic> get _settings => HiveService.settingsBox;

  // ── Read ───────────────────────────────────────────────────────────────────

  @override
  UserModel? getCurrentUser() {
    final userId = _settings.get(_kActiveUserIdKey) as String?;
    if (userId == null) return null;
    return _box.get(userId);
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  @override
  Future<void> saveUser(UserModel user) async {
    // Record the active user, then persist the model under their id.
    await _settings.put(_kActiveUserIdKey, user.id);
    await _box.put(user.id, user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    // Key might not be set yet if called before saveUser; set it anyway.
    await _settings.put(_kActiveUserIdKey, user.id);
    await _box.put(user.id, user);
  }

  @override
  Future<void> clearUser() async {
    // Remove the active pointer but KEEP the user record in the box so
    // logging back in with the same account restores data from cloud sync.
    await _settings.delete(_kActiveUserIdKey);
  }
}
