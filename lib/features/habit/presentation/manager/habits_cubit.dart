import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart' as hive;
import 'package:habit_iq/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_state.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HabitsCubit
///
/// Single source of truth for the habits list, daily progress, and streak.
/// ─────────────────────────────────────────────────────────────────────────────
class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit(this._repo) : super(const HabitsInitial());

  final HabitRepository _repo;

  // ── Load ───────────────────────────────────────────────────────────────────

  void loadTodayHabits() {
    try {
      final hiveHabits = _repo.getTodayHabits();

      // One-time cleanup: delete sample habits seeded by a previous build.
      final sampleIds = hiveHabits
          .where((h) => h.id.startsWith('sample_'))
          .map((h) => h.id)
          .toList();
      if (sampleIds.isNotEmpty) {
        Future.wait(
          sampleIds.map(_repo.deleteHabit),
        ).then((_) => loadTodayHabits());
        return;
      }

      // Auto-reset: if a habit is flagged completed but was done on a
      // previous day (not today), clear the stale flag.
      final today = _today();
      for (final h in hiveHabits) {
        if (h.isCompletedToday) {
          final doneToday = h.completionDates.any((d) => _sameDay(d, today));
          if (!doneToday) {
            h.isCompletedToday = false;
            h.save(); // persist to Hive synchronously
          }
        }
      }

      final completed = hiveHabits.where((h) => h.isCompletedToday).length;
      final progress = hiveHabits.isEmpty ? 0.0 : completed / hiveHabits.length;
      final streak = _computeOverallStreak(hiveHabits);

      emit(
        HabitsLoaded(
          habits: hiveHabits,
          dailyProgress: progress,
          streakCount: streak,
        ),
      );
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  /// Resets the `isCompletedToday` flag for all habits.
  ///
  /// This is useful for testing or for manually resetting daily progress.
  Future<void> resetDailyFlags() async {
    try {
      final hiveHabits = _repo.getTodayHabits();
      for (final h in hiveHabits) {
        if (h.isCompletedToday) {
          h.isCompletedToday = false;
          await _repo.updateHabit(h); // Persist the change
        }
      }
      loadTodayHabits(); // Reload habits to reflect changes
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Add ────────────────────────────────────────────────────────────────────

  Future<void> addNewHabit(
    String title,
    IconData icon,
    Color color, {
    int frequency = 0,
    int targetDays = 66,
    bool hasReminder = false,
    DateTime? reminderTime,
  }) async {
    try {
      final habit = hive.HabitModel(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        icon: icon.codePoint,
        colorHex:
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
        createdAt: DateTime.now(),
        frequency: frequency,
        targetDays: targetDays,
        hasReminder: hasReminder,
        reminderTime: reminderTime,
      );
      await _repo.addHabit(habit);
      loadTodayHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Toggle ─────────────────────────────────────────────────────────────────

  Future<void> toggleHabitCompletion(String id) async {
    final habit = _repo.getTodayHabits().firstWhere(
      (h) => h.id == id,
      orElse: () => throw StateError('Habit $id not found'),
    );

    final today = _today();
    final alreadyCompleted = habit.isCompletedToday;

    if (alreadyCompleted) {
      habit.completionDates.removeWhere((d) => _sameDay(d, today));
      habit.isCompletedToday = false;
    } else {
      if (!habit.completionDates.any((d) => _sameDay(d, today))) {
        habit.completionDates.add(today);
      }
      habit.isCompletedToday = true;
    }

    await _repo.updateHabit(habit);
    loadTodayHabits();
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteHabit(String id) async {
    await _repo.deleteHabit(id);
    loadTodayHabits();
  }

  // ── Update Reminder ────────────────────────────────────────────────────────

  Future<void> updateReminder(
    String habitId,
    bool hasReminder,
    DateTime? reminderTime,
  ) async {
    try {
      final habit = _repo.getTodayHabits().firstWhere((h) => h.id == habitId);
      habit.hasReminder = hasReminder;
      habit.reminderTime = reminderTime;
      await _repo.updateHabit(habit);
      loadTodayHabits(); // Refresh UI
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Overall streak computation ──────────────────────────────────────────────

  /// Counts consecutive days (going backwards from today) on which at least
  /// one daily habit was marked completed.
  int _computeOverallStreak(List<hive.HabitModel> habits) {
    if (habits.isEmpty) return 0;

    // Collect unique days where any habit was completed.
    final completedDays = <DateTime>{};
    for (final h in habits) {
      for (final d in h.completionDates) {
        completedDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    if (completedDays.isEmpty) return 0;

    int streak = 0;
    DateTime cursor = _today();

    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
