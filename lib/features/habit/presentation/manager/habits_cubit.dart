import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart' as hive;
import 'package:habit_iq/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_state.dart';
import 'package:habit_iq/features/home/domain/models/habit_model.dart' as ui;

/// ─────────────────────────────────────────────────────────────────────────────
/// HabitsCubit
///
/// Single source of truth for the habits list and daily progress.
///
/// Architecture note: the cubit owns the mapping between the Hive entity
/// ([hive.HabitModel]) and the UI entity ([ui.HabitModel]). This keeps widgets
/// dumb — they only know about the UI model.
///
/// Wire up in main.dart:
/// ```dart
/// BlocProvider<HabitsCubit>(
///   create: (_) => HabitsCubit(HabitRepositoryImpl())..loadTodayHabits(),
/// )
/// ```
/// ─────────────────────────────────────────────────────────────────────────────
class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit(this._repo) : super(const HabitsInitial());

  final HabitRepository _repo;

  // ── Load ───────────────────────────────────────────────────────────────────

  /// Reads all habits from Hive, maps them to UI models, calculates
  /// daily progress, and emits [HabitsLoaded].
  ///
  /// Call once on startup and after every mutation.
  void loadTodayHabits() {
    try {
      final hiveHabits = _repo.getTodayHabits();

      // One-time cleanup: delete any habit seeded by a previous build.
      // Safe to await-forget — the next loadTodayHabits call (after deletion)
      // will see a clean box.
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

      final uiHabits = hiveHabits.map(_toUiModel).toList();
      final completed = uiHabits.where((h) => h.isCompleted).length;
      final progress = uiHabits.isEmpty ? 0.0 : completed / uiHabits.length;

      emit(HabitsLoaded(habits: uiHabits, dailyProgress: progress));
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Add ────────────────────────────────────────────────────────────────────

  /// Creates a new [hive.HabitModel] from the given parameters, saves it to
  /// Hive, then refreshes the list.
  Future<void> addNewHabit(String title, IconData icon, Color color) async {
    try {
      final habit = hive.HabitModel(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        icon: icon.codePoint,
        colorHex:
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
        createdAt: DateTime.now(),
      );
      await _repo.addHabit(habit);
      loadTodayHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ── Toggle ─────────────────────────────────────────────────────────────────

  /// Finds the habit with [id], flips [isCompletedToday], syncs
  /// [completionDates], persists to Hive, then refreshes the list.
  Future<void> toggleHabitCompletion(String id) async {
    // Read directly from the box so we always work on the latest data.
    final habit = _repo.getTodayHabits().firstWhere(
      (h) => h.id == id,
      orElse: () => throw StateError('Habit $id not found'),
    );

    final today = _today();
    final alreadyCompleted = habit.isCompletedToday;

    if (alreadyCompleted) {
      // Un-complete: remove today from completionDates.
      habit.completionDates.removeWhere((d) => _sameDay(d, today));
      habit.isCompletedToday = false;
    } else {
      // Complete: add today if not already present.
      if (!habit.completionDates.any((d) => _sameDay(d, today))) {
        habit.completionDates.add(today);
      }
      habit.isCompletedToday = true;
    }

    await _repo.updateHabit(habit);
    loadTodayHabits();
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Removes a habit permanently from Hive and refreshes the list.
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
      subtitle: '${h.currentStreak} day streak · ${h.totalCompletions} total',
      icon: IconData(h.icon, fontFamily: 'MaterialIcons'),
      isCompleted: h.isCompletedToday,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
