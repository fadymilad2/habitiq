import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Hive TypeId registry:
///   0 → UserModel
///   1 → HabitModel
///   2 → MoodEntryModel

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// Relative path to the user's avatar asset / file.
  @HiveField(2)
  String? avatarPath;

  /// Gamification level (1-based).
  @HiveField(3)
  int level;

  @HiveField(4)
  final DateTime createdAt;

  /// Total XP accumulated within the current level (0 – [xpPerLevel]).
  @HiveField(5)
  int xp;

  /// Current consecutive-day habit streak.
  @HiveField(6)
  int streakCount;

  /// XP required to advance one level.
  static const int xpPerLevel = 100;

  UserModel({
    required this.id,
    required this.name,
    this.avatarPath,
    this.level = 1,
    required this.createdAt,
    this.xp = 0,
    this.streakCount = 0,
  });

  /// Progress within the current level, in the range [0.0, 1.0].
  double get levelProgress => (xp / xpPerLevel).clamp(0.0, 1.0);

  /// Convenience factory for a brand-new user.
  factory UserModel.create({required String id, required String name}) {
    return UserModel(
      id: id,
      name: name,
      level: 1,
      xp: 0,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, level: $level, xp: $xp, streakCount: $streakCount)';
}
