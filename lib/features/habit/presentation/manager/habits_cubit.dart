import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart' as hive;
import 'package:habit_iq/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_state.dart';
import 'package:habit_iq/features/home/domain/models/habit_model.dart' as ui;

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

      final uiHabits = hiveHabits.map(_toUiModel).toList();
      final completed = uiHabits.where((h) => h.isCompleted).length;
      final progress = uiHabits.isEmpty ? 0.0 : completed / uiHabits.length;
      final streak = _computeOverallStreak(hiveHabits);

      emit(
        HabitsLoaded(
          habits: uiHabits,
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

  // ── Mapping ────────────────────────────────────────────────────────────────

  /// Maps a Hive [hive.HabitModel] → [ui.HabitModel] for widget consumption.
  ui.HabitModel _toUiModel(hive.HabitModel h) {
    return ui.HabitModel(
      id: h.id,
      title: h.title,
      subtitle: _buildSubtitle(h),
      icon: IconData(h.icon, fontFamily: 'MaterialIcons'),
      isCompleted: h.isCompletedToday,
    );
  }

  /// Builds a subtitle string that reflects the habit's frequency.
  ///
  /// - Daily   → "5 day streak · 12 total"
  /// - Weekly  → "Mon, Wed, Fri · 12 total"  (placeholder days for now)
  /// - Custom  → "Custom schedule · 12 total"
  String _buildSubtitle(hive.HabitModel h) {
    final total = h.totalCompletions;
    final streak = h.currentStreak;

    switch (h.frequency) {
      case 1: // Weekly
        return 'Weekly · $total total';
      case 2: // Custom
        return 'Custom schedule · $total total';
      case 0: // Daily (default)
      default:
        if (streak == 0) return '$total total completions';
        return '$streak day streak · $total total';
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
