import 'dart:convert';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/core/config/app_secrets.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_iq/features/mood/data/models/mood_entry_model.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_state.dart';
import 'package:http/http.dart' as http;

class AICubit extends Cubit<AIState> {
  AICubit(this._repo) : super(const AIInitial()) {
    _loadHistoricalData();
  }

  final HabitRepository _repo;

  static const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  // State caches for the UI
  List<FlSpot> _moodChartData = [];
  List<FlSpot> _habitChartData = [];
  Map<String, int> _monthlyMoodCounts = {};
  double _correlationValue = 0.0;

  void resetToInitial() => emit(const AIInitial());

  /// Used on init to populate the charts even before the user logs a mood today.
  void _loadHistoricalData() {
    _computeChartData();
    if (state is AILoaded) {
      final current = state as AILoaded;
      emit(
        AILoaded(
          message: current.message,
          currentMood: current.currentMood,
          moodChartData: _moodChartData,
          habitChartData: _habitChartData,
          monthlyMoodCounts: _monthlyMoodCounts,
          correlationValue: _correlationValue,
        ),
      );
    }
  }

  Future<void> logMoodAndGenerateInsight(
    String userName,
    double dailyProgress,
    String mood, // e.g., 'Happy', 'Sad', etc.
    int intensity,
    List<String> completedHabits,
  ) async {
    // 1. Save Mood to Hive
    final today = _zeroTime(DateTime.now());
    final existingIndex = HiveService.moodsBox.values.toList().indexWhere(
      (m) => m.date.isAtSameMomentAs(today),
    );

    final newEntry = MoodEntryModel(
      id: 'mood_${today.millisecondsSinceEpoch}',
      date: today,
      moodType: mood.toLowerCase(),
      intensity: intensity,
    );

    if (existingIndex != -1) {
      final key = HiveService.moodsBox.keyAt(existingIndex);
      await HiveService.moodsBox.put(key, newEntry);
    } else {
      await HiveService.moodsBox.add(newEntry);
    }

    // 2. Compute correlation and monthly stat data (updates local cache)
    _computeChartData(currentMood: mood);

    // 3. Call AI
    final apiKey = AppSecrets.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'PASTE_YOUR_API_KEY_HERE') {
      emit(const AIError('نسيت تحط مفتاح Groq يا هندسة!'));
      return;
    }

    emit(const AILoading());

    try {
      final completedList = completedHabits.isEmpty
          ? 'Nothing yet'
          : completedHabits.join(', ');

      final systemPrompt = '''
You are a highly supportive, empathetic friend texting your buddy casually (like on WhatsApp).
Your task: Write a very short message (maximum 2 sentences) to encourage them based on their mood and today's progress.
- If they are Sad, Stressed, or Tired: Comfort them genuinely. Validate their feelings, tell them it's completely normal to have heavy days, and remind them not to be hard on themselves.
- If they are Happy or Calm: Hype them up! Celebrate their energy and keep their momentum going.
- NEVER use robotic or formal greetings like "Hello", "Hi", or "Dear". Jump straight into the conversation naturally using their name.
- Use 1 or 2 emojis maximum that fit the vibe.
''';

      final userPrompt =
          '''
Friend's name: $userName
Current mood: $mood
Today's progress: ${(dailyProgress * 100).toInt()}%
Completed habits: $completedList
''';

      final response = await http
          .post(
            Uri.parse(_groqUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.7,
              'max_tokens': 150,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'].toString().trim();
        emit(
          AILoaded(
            message: text,
            currentMood: mood,
            moodChartData: _moodChartData,
            habitChartData: _habitChartData,
            monthlyMoodCounts: _monthlyMoodCounts,
            correlationValue: _correlationValue,
          ),
        );
      } else {
        log('Groq API Error: ${response.statusCode}');
        emit(const AIError('معلش السيرفر واقع دلوقتي، جرب تاني كمان شوية.'));
      }
    } catch (e) {
      log('Unexpected Error: $e');
      emit(const AIError('حصلت مشكلة في النت أو في قراءة الرد.'));
    }
  }

  // ── Analytics Computation ────────────────────────────────────────────────

  void _computeChartData({String? currentMood}) {
    final now = DateTime.now();
    final today = _zeroTime(now);

    final habits = _repo.getTodayHabits();
    final moods = HiveService.moodsBox.values.toList();

    // 1. Chart Data (Last 7 Days)
    List<FlSpot> moodSpots = [];
    List<FlSpot> habitSpots = [];

    // FlChart requires spots sorted by x.
    // x = 0 (6 days ago), x = 1 (5 days ago) ... x = 6 (today)
    for (int offset = 6; offset >= 0; offset--) {
      final day = today.subtract(Duration(days: offset));
      final xVal = (6 - offset).toDouble(); // 0 to 6

      // Mood score: mapping string -> double
      final dayMood = moods
          .where((m) => m.date.isAtSameMomentAs(day))
          .firstOrNull;
      double yMood = 3.0; // default middle if no data
      if (dayMood != null) {
        yMood = _moodStringToScore(dayMood.moodType);
      }
      moodSpots.add(FlSpot(xVal, yMood));

      // Habit score: map percentage to 1-5 scale to match mood graph
      double yHabit = 1.0;
      if (habits.isNotEmpty) {
        int done = habits
            .where(
              (h) => h.completionDates.any(
                (d) => _zeroTime(d).isAtSameMomentAs(day),
              ),
            )
            .length;
        // 0% -> 1.0, 100% -> 5.0
        yHabit = 1.0 + ((done / habits.length) * 4.0);
      }
      habitSpots.add(FlSpot(xVal, yHabit));
    }

    // 2. Monthly Summary Data (Current Month)
    int great = 0;
    int okay = 0;
    int low = 0;

    for (final m in moods) {
      if (m.date.year == now.year && m.date.month == now.month) {
        final score = _moodStringToScore(m.moodType);
        if (score >= 4.0) {
          great++;
        } else if (score >= 3.0) {
          okay++;
        } else {
          low++;
        }
      }
    }

    // 3. Dynamic Correlation Score based on current mood
    // Calculates the average habit completion percentage specifically on the days the user felt `currentMood`
    double avgHabitOnThisMood = 0.0;

    if (currentMood != null) {
      int matchedDaysCount = 0;
      double totalHabitPercentSum = 0.0;

      for (final m in moods) {
        if (m.moodType.toLowerCase() == currentMood.toLowerCase()) {
          matchedDaysCount++;

          int done = habits
              .where(
                (h) => h.completionDates.any(
                  (d) => _zeroTime(d).isAtSameMomentAs(m.date),
                ),
              )
              .length;
          double percent = habits.isEmpty ? 0 : done / habits.length;
          totalHabitPercentSum += percent;
        }
      }

      if (matchedDaysCount > 0) {
        avgHabitOnThisMood = totalHabitPercentSum / matchedDaysCount;
      }
    }

    _moodChartData = moodSpots;
    _habitChartData = habitSpots;
    _monthlyMoodCounts = {'great': great, 'okay': okay, 'low': low};
    _correlationValue = avgHabitOnThisMood;
  }

  double _moodStringToScore(String moodType) {
    switch (moodType.toLowerCase()) {
      case 'amazing':
        return 5.0;
      case 'good':
        return 4.0;
      case 'okay':
        return 3.0;
      case 'bad':
        return 2.0;
      case 'terrible':
        return 1.0;
      default:
        return 3.0; // Assume okay for unknowns
    }
  }

  static DateTime _zeroTime(DateTime d) => DateTime(d.year, d.month, d.day);
}
