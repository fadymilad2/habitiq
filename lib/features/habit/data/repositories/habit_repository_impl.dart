import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart';
import 'package:habit_iq/features/habit/domain/repositories/habit_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Hive-backed implementation of [HabitRepository].
///
/// Storage strategy:
///   • Every [HabitModel] is stored with its [HabitModel.id] as the Hive key.
///   • This gives O(1) single-item reads/deletes without scanning the box.
/// ─────────────────────────────────────────────────────────────────────────────
class HabitRepositoryImpl implements HabitRepository {
  /// Typed reference to the Hive box opened by [HiveService].
  Box<HabitModel> get _box => HiveService.habitsBox;

  // ── Read ───────────────────────────────────────────────────────────────────

  @override
  List<HabitModel> getTodayHabits() {
    // Return all stored habits; the cubit decides what "today" means.
    return _box.values.toList();
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  @override
  Future<void> addHabit(HabitModel habit) async {
    await _box.put(habit.id, habit);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    // Same as add — overwrite by key.
    await _box.put(habit.id, habit);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
  }
}
