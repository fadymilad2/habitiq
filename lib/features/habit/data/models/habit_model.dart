import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 1)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  /// Codepoint of the [IconData] to display (e.g. `Icons.fitness_center.codePoint`).
  @HiveField(2)
  int icon;

  /// Hex color string (e.g. `"#7C3AED"`).
  @HiveField(3)
  String colorHex;

  /// Whether the habit has been tapped as done for today's session.
  @HiveField(4)
  bool isCompletedToday;

  /// Each [DateTime] in this list represents a day the habit was completed.
  /// Store only date components (time zeroed out) for easy comparison.
  @HiveField(5)
  List<DateTime> completionDates;

  @HiveField(6)
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.colorHex,
    this.isCompletedToday = false,
    List<DateTime>? completionDates,
    required this.createdAt,
  }) : completionDates = completionDates ?? [];

  /// Marks today as completed and sets [isCompletedToday] to `true`.
  void markCompleted() {
    final today = _today();
    if (!completionDates.any((d) => _sameDay(d, today))) {
      completionDates.add(today);
    }
    isCompletedToday = true;
    save(); // Persist to Hive immediately.
  }

  /// Resets [isCompletedToday] — call at midnight / new day.
  void resetDailyFlag() {
    isCompletedToday = false;
    save();
  }

  /// Returns the total number of days the habit was completed.
  int get totalCompletions => completionDates.length;

  /// Returns the current streak (consecutive days ending today or yesterday).
  int get currentStreak {
    if (completionDates.isEmpty) return 0;
    final sorted = List<DateTime>.from(completionDates)
      ..sort((a, b) => b.compareTo(a)); // most-recent first
    int streak = 0;
    DateTime cursor = _today();
    for (final date in sorted) {
      if (_sameDay(date, cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (date.isBefore(cursor)) {
        break; // gap found
      }
    }
    return streak;
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  String toString() =>
      'HabitModel(id: $id, title: $title, streak: $currentStreak)';
}
