import 'package:habit_iq/features/habit/data/models/habit_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Abstract contract for all habit persistence operations.
///
/// The cubit layer depends on THIS interface, never on concrete Hive impl.
/// ─────────────────────────────────────────────────────────────────────────────
abstract class HabitRepository {
  /// Returns ALL habits currently stored in the box.
  ///
  /// "Today's habits" filtering is intentionally left to the cubit layer so
  /// the repo stays a pure storage abstraction.
  List<HabitModel> getTodayHabits();

  /// Persists a brand-new [habit] to the box (keyed by [HabitModel.id]).
  Future<void> addHabit(HabitModel habit);

  /// Overwrites an existing habit entry with updated data from [habit].
  Future<void> updateHabit(HabitModel habit);

  /// Removes the habit identified by [id] from the box.
  Future<void> deleteHabit(String id);
}
