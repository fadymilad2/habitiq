import 'package:hive/hive.dart';

part 'mood_entry_model.g.dart';

/// Predefined mood type string constants — use these to avoid magic strings.
class MoodType {
  MoodType._();
  static const amazing = 'amazing';
  static const good = 'good';
  static const okay = 'okay';
  static const bad = 'bad';
  static const terrible = 'terrible';
}

@HiveType(typeId: 2)
class MoodEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  /// The date of the mood log. Store only date components (time zeroed out).
  @HiveField(1)
  final DateTime date;

  /// One of [MoodType] constants (e.g. `MoodType.good`).
  @HiveField(2)
  String moodType;

  /// Intensity from 1 (lowest) to 5 (highest).
  @HiveField(3)
  int intensity;

  MoodEntryModel({
    required this.id,
    required this.date,
    required this.moodType,
    required this.intensity,
  }) : assert(
         intensity >= 1 && intensity <= 5,
         'Intensity must be between 1 and 5.',
       );

  /// Factory for today's mood log.
  factory MoodEntryModel.forToday({
    required String id,
    required String moodType,
    required int intensity,
  }) {
    final now = DateTime.now();
    return MoodEntryModel(
      id: id,
      date: DateTime(now.year, now.month, now.day),
      moodType: moodType,
      intensity: intensity,
    );
  }

  @override
  String toString() =>
      'MoodEntryModel(date: $date, mood: $moodType, intensity: $intensity)';
}
