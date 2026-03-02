/// ─────────────────────────────────────────────────────────────────────────────
/// AnalyticsState — sealed hierarchy consumed by [AnalyticsCubit].
///
/// Design notes:
///  • Sealed so the compiler enforces exhaustive `switch` handling in widgets.
///  • [AnalyticsLoaded] is intentionally immutable (all fields are `final`).
///    Rebuild is driven by a new `emit`; no internal mutation.
/// ─────────────────────────────────────────────────────────────────────────────
sealed class AnalyticsState {
  const AnalyticsState();
}

// ── 1. Initial ───────────────────────────────────────────────────────────────

/// The cubit was just created and has not yet loaded any data.
final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

// ── 2. Loading ───────────────────────────────────────────────────────────────

/// An async data read is in progress. Show a loading spinner.
final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

// ── 3. Loaded ────────────────────────────────────────────────────────────────

/// A single data point in the completion chart.
///
/// Using a date-stamped model (rather than a bare `double`) gives the chart
/// widget precise calendar information — it knows exactly which day each spot
/// corresponds to, so it can generate accurate axis labels and skip "dead"
/// days that precede the first habit creation.
class DayEntry {
  const DayEntry({required this.date, required this.value});

  /// Calendar day this entry represents (time zeroed to midnight).
  final DateTime date;

  /// Completion fraction [0.0, 1.0]: (habits done that day) / (total habits).
  final double value;
}

/// A single monthly data point for the ALL-time chart.
class MonthEntry {
  const MonthEntry({
    required this.year,
    required this.month,
    required this.value,
  });

  final int year;
  final int month;

  /// Completion fraction [0.0, 1.0].
  final double value;
}

/// All analytics have been calculated successfully.
///
/// The periodic lists ([periodicWeekly], [periodicMonthly]) only contain
/// entries on or after [appStartDate], eliminating "dead day" flat-zero lines
/// that would appear before the user ever created a habit.
final class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded({
    required this.appStartDate,
    required this.currentStreak,
    required this.bestStreak,
    required this.periodicWeekly,
    required this.periodicMonthly,
    required this.allTimeMonthly,
    required this.heatMapData,
    required this.totalCompletions,
    required this.totalActiveDays,
  });

  /// The date of the earliest [HabitModel.createdAt] across all habits.
  /// Used by the chart to know where to start plotting.
  final DateTime appStartDate;

  final int currentStreak;
  final int bestStreak;

  /// Day-stamped completion entries for the last 7 calendar days,
  /// **filtered to only include days on or after [appStartDate]**.
  final List<DayEntry> periodicWeekly;

  /// Day-stamped completion entries for the last 30 calendar days,
  /// **filtered to only include days on or after [appStartDate]**.
  final List<DayEntry> periodicMonthly;

  /// Monthly aggregate entries from the first habit's creation month
  /// up to (and including) the current month.
  final List<MonthEntry> allTimeMonthly;

  /// date (time zeroed) → completion percentage 0–100.
  final Map<DateTime, int> heatMapData;

  /// All-time sum of completions across every habit.
  final int totalCompletions;

  /// The number of unique calendar days on which at least one habit was completed.
  final int totalActiveDays;

  double get weeklyAverage {
    final activeEntries = periodicWeekly
        .where((e) => !e.date.isBefore(appStartDate))
        .toList();
    if (activeEntries.isEmpty) return 0.0;
    return activeEntries.fold(0.0, (sum, e) => sum + e.value) /
        activeEntries.length;
  }

  double get monthlyAverage {
    final activeEntries = periodicMonthly
        .where((e) => !e.date.isBefore(appStartDate))
        .toList();
    if (activeEntries.isEmpty) return 0.0;
    return activeEntries.fold(0.0, (sum, e) => sum + e.value) /
        activeEntries.length;
  }

  double get allTimeAverage {
    final activeEntries = allTimeMonthly.where((e) {
      if (e.year < appStartDate.year) return false;
      if (e.year == appStartDate.year && e.month < appStartDate.month) {
        return false;
      }
      return true;
    }).toList();
    if (activeEntries.isEmpty) return 0.0;
    return activeEntries.fold(0.0, (sum, e) => sum + e.value) /
        activeEntries.length;
  }

  @override
  String toString() =>
      'AnalyticsLoaded('
      'streak=$currentStreak, '
      'best=$bestStreak, '
      'totalCompletions=$totalCompletions, '
      'totalActiveDays=$totalActiveDays'
      ')';
}

// ── 4. Error ─────────────────────────────────────────────────────────────────

/// An error occurred while loading analytics. Show a retry button or message.
final class AnalyticsError extends AnalyticsState {
  const AnalyticsError(this.message);

  final String message;
}
