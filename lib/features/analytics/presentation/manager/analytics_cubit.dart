import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_state.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart';
import 'package:habit_iq/features/habit/domain/repositories/habit_repository.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AnalyticsCubit
///
/// Single responsibility: read all [HabitModel] records from [HabitRepository]
/// and derive the analytics values consumed by the Analytics UI.
///
/// The key invariant enforced here is the "Dead-Day" fix:
///   No data point is ever generated for a calendar day that precedes
///   [appStartDate] — the earliest [HabitModel.createdAt] across all habits.
///   This means charts start exactly where the user's journey started,
///   not artificially flat 7 or 30 days back.
///
/// Wire-up in `main.dart`:
/// ```dart
/// BlocProvider<AnalyticsCubit>(
///   create: (_) => AnalyticsCubit(HabitRepositoryImpl())..loadAnalytics(),
/// )
/// ```
/// ─────────────────────────────────────────────────────────────────────────────
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(this._repo) : super(const AnalyticsInitial());

  final HabitRepository _repo;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Reads all habits from Hive and emits [AnalyticsLoaded] with computed stats.
  ///
  /// Safe to call multiple times — each call re-reads and re-computes from
  /// scratch, so analytics always reflect the latest Hive state.
  void loadAnalytics() {
    emit(const AnalyticsLoading());

    try {
      final habits = _repo.getTodayHabits();

      // The earliest createdAt across all habits defines "day zero" for this
      // user. Days before this anchor are never plotted ("Dead-Day" fix).
      final appStartDate = _findAppStartDate(habits);

      emit(
        AnalyticsLoaded(
          appStartDate: appStartDate,
          currentStreak: _computeCurrentStreak(habits),
          bestStreak: _computeBestStreak(habits),
          periodicWeekly: _computePeriodicEntries(habits, appStartDate, 7),
          periodicMonthly: _computePeriodicEntries(habits, appStartDate, 30),
          allTimeMonthly: _computeAllTimeMonthly(habits, appStartDate),
          heatMapData: _computeHeatMap(habits),
          totalCompletions: _computeTotalCompletions(habits),
          totalActiveDays: _computeTotalActiveDays(habits),
        ),
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('[AnalyticsCubit] loadAnalytics error: $e\n$st');
        return true;
      }());
      emit(AnalyticsError(e.toString()));
    }
  }

  // ── App Start Date ─────────────────────────────────────────────────────────

  /// Returns the earliest [HabitModel.createdAt] (time-zeroed) across all
  /// habits, which defines the first day the user could have completed anything.
  ///
  /// Falls back to today when no habits exist, so the chart window is still
  /// consistent even if the box is empty.
  DateTime _findAppStartDate(List<HabitModel> habits) {
    if (habits.isEmpty) return _today();
    DateTime earliest = _zeroTime(habits.first.createdAt);
    for (final h in habits) {
      final d = _zeroTime(h.createdAt);
      if (d.isBefore(earliest)) earliest = d;
    }
    return earliest;
  }

  // ── Calculation: Current Streak ────────────────────────────────────────────

  /// Consecutive calendar days *ending today or yesterday* on which at least
  /// one habit was completed across the whole portfolio.
  int _computeCurrentStreak(List<HabitModel> habits) {
    final completedDays = <DateTime>{};
    for (final h in habits) {
      for (final d in h.completionDates) {
        completedDays.add(_zeroTime(d));
      }
    }
    if (completedDays.isEmpty) return 0;

    final today = _today();
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime cursor;
    if (completedDays.contains(today)) {
      cursor = today;
    } else if (completedDays.contains(yesterday)) {
      cursor = yesterday;
    } else {
      return 0;
    }

    int streak = 0;
    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // ── Calculation: Best Streak ───────────────────────────────────────────────

  /// Longest consecutive run on any single habit, ever.
  int _computeBestStreak(List<HabitModel> habits) {
    int globalBest = 0;
    for (final h in habits) {
      if (h.completionDates.isEmpty) continue;
      final sorted = h.completionDates.map(_zeroTime).toSet().toList()..sort();
      int run = 1;
      int best = 1;
      for (int i = 1; i < sorted.length; i++) {
        final diff = sorted[i].difference(sorted[i - 1]).inDays;
        if (diff == 1) {
          run++;
          if (run > best) best = run;
        } else {
          run = 1;
        }
      }
      if (best > globalBest) globalBest = best;
    }
    return globalBest;
  }

  // ── Calculation: Periodic Day Entries (7D / 30D) ──────────────────────────

  /// Builds a [DayEntry] list covering the last [windowDays] calendar days,
  /// **but skipping any day that falls before [appStartDate]**.
  ///
  /// This is the core of the Dead-Day fix:
  ///  • The returned list may be shorter than [windowDays] for new users.
  ///  • Each entry carries its own [DateTime] so the chart can generate
  ///    accurate axis labels without re-deriving the date from an index.
  ///
  /// Average shown in the chart header is computed only over this filtered
  /// list, so a user who joined 3 days ago sees a 3-day average.
  List<DayEntry> _computePeriodicEntries(
    List<HabitModel> habits,
    DateTime appStartDate,
    int windowDays,
  ) {
    final today = _today();
    final result = <DayEntry>[];

    for (int offset = windowDays - 1; offset >= 0; offset--) {
      final day = today.subtract(Duration(days: offset));

      // ── Zero-pad pre-join days ────────────────────────────────────────────
      // Inject zeroes for days before the first habit creation to keep arrays
      // correctly sized for the visual charts.
      if (day.isBefore(appStartDate)) {
        result.add(DayEntry(date: day, value: 0.0));
        continue;
      }

      final value = habits.isEmpty
          ? 0.0
          : () {
              int done = 0;
              for (final h in habits) {
                if (h.completionDates.any((d) => _sameDay(d, day))) done++;
              }
              return done / habits.length;
            }();

      result.add(DayEntry(date: day, value: value));
    }

    return result;
  }

  // ── Calculation: All-Time Monthly ─────────────────────────────────────────

  /// One [MonthEntry] per calendar month from the month of [appStartDate]
  /// up to (and including) the current month.
  ///
  /// For the current (partial) month the denominator uses only the days
  /// elapsed so far (not the full month), so a new user on March 3rd has
  /// a denominator of 3 × habits, not 31 × habits.
  List<MonthEntry> _computeAllTimeMonthly(
    List<HabitModel> habits,
    DateTime appStartDate,
  ) {
    if (habits.isEmpty) {
      final now = DateTime.now();
      return [MonthEntry(year: now.year, month: now.month, value: 0.0)];
    }

    final today = _today();
    final result = <MonthEntry>[];

    int year = appStartDate.year;
    int month = appStartDate.month;

    while (DateTime(year, month).compareTo(DateTime(today.year, today.month)) <=
        0) {
      final isCurrentMonth = year == today.year && month == today.month;

      // For complete past months use all days; for the current (partial) month
      // use only the days elapsed so far to avoid deflating the rate.
      final int daysToCount;
      if (isCurrentMonth) {
        // Days elapsed in the current month from the start anchor:
        // if appStart is in this month, count from its day; otherwise from 1.
        final startDay =
            (year == appStartDate.year && month == appStartDate.month)
            ? appStartDate.day
            : 1;
        daysToCount = today.day - startDay + 1;
      } else {
        // Full month, but if appStart is in this month, start from its day.
        final startDay =
            (year == appStartDate.year && month == appStartDate.month)
            ? appStartDate.day
            : 1;
        final daysInMonth = DateTime(year, month + 1, 0).day;
        daysToCount = daysInMonth - startDay + 1;
      }

      final maxCompletions = habits.length * daysToCount;

      int actual = 0;
      for (final h in habits) {
        for (final d in h.completionDates) {
          if (d.year == year && d.month == month) actual++;
        }
      }

      result.add(
        MonthEntry(
          year: year,
          month: month,
          value: maxCompletions > 0
              ? (actual / maxCompletions).clamp(0, 1)
              : 0.0,
        ),
      );

      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    // ── Single Dot Fix ──────────────────────────────────────────────────────
    // If the length is 1 (user joined this exact month), fl_chart will
    // only draw a single floating dot. Prepend a dummy 0.0 entry for the
    // previous month so a line is drawn from 0 to current.
    if (result.length == 1) {
      int prevMonth = result.first.month - 1;
      int prevYear = result.first.year;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear--;
      }
      result.insert(
        0,
        MonthEntry(year: prevYear, month: prevMonth, value: 0.0),
      );
    }

    return result;
  }

  // ── Calculation: Heat-map Data ─────────────────────────────────────────────

  /// date → completion percentage 0–100 for the past 91 days.
  Map<DateTime, int> _computeHeatMap(List<HabitModel> habits) {
    final result = <DateTime, int>{};
    final today = _today();
    final totalHabits = habits.length;

    for (int offset = 90; offset >= 0; offset--) {
      final day = today.subtract(Duration(days: offset));
      if (totalHabits == 0) {
        result[day] = 0;
        continue;
      }
      int done = 0;
      for (final h in habits) {
        if (h.completionDates.any((d) => _sameDay(d, day))) done++;
      }
      result[day] = ((done / totalHabits) * 100).round();
    }

    return result;
  }

  // ── Calculation: Total Completions & Days ────────────────────────────────

  int _computeTotalCompletions(List<HabitModel> habits) =>
      habits.fold(0, (sum, h) => sum + h.completionDates.length);

  int _computeTotalActiveDays(List<HabitModel> habits) {
    final uniqueDates = <DateTime>{};
    for (final h in habits) {
      for (final d in h.completionDates) {
        uniqueDates.add(_zeroTime(d));
      }
    }
    return uniqueDates.length;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _zeroTime(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
