import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/core/config/app_secrets.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_state.dart';
import 'package:http/http.dart' as http;

class AICubit extends Cubit<AIState> {
  AICubit() : super(const AIInitial());

  // استخدمنا سيرفرات Groq الصاروخية مع أذكى موديل من Llama 3
  static const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  void resetToInitial() => emit(const AIInitial());

  Future<void> generateDailyInsight(
    String userName,
    double dailyProgress,
    String mood,
    List<String> completedHabits,
  ) async {
    // ⚠️ مهم جداً: هتحط هنا المفتاح بتاع Groq في ملف الأسرار
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

      // البرومبت الإنجليزي بأسلوب الصاحب الجدع
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

      log('Groq Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'].toString().trim();
        emit(AILoaded(message: text, currentMood: mood));
      } else {
        log('Groq API Error: ${response.statusCode}');
        emit(const AIError('معلش السيرفر واقع دلوقتي، جرب تاني كمان شوية.'));
      }
    } catch (e) {
      log('Unexpected Error: $e');
      emit(const AIError('حصلت مشكلة في النت أو في قراءة الرد.'));
    }
  }
}
