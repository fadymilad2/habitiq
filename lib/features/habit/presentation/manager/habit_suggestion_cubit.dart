import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/core/config/app_secrets.dart';
import 'package:http/http.dart' as http;

import 'habit_suggestion_state.dart';

/// Calls the Groq API to generate a short, actionable habit suggestion.
///
/// The model returns a **strict JSON object**:
/// ```json
/// { "name": "Read 10 Pages", "icon_index": 0, "color_index": 2 }
/// ```
/// Indices map to the icon/color lists in [VisualIdentitySection].
class HabitSuggestionCubit extends Cubit<HabitSuggestionState> {
  HabitSuggestionCubit() : super(const HabitSuggestionInitial());

  static const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  // Icon indices correspond to VisualIdentitySection._icons:
  // 0=book, 1=fitness, 2=water, 3=code, 4=meditation, 5=moon, 6=bike, 7=savings, 8=palette

  // Color indices correspond to VisualIdentitySection._colors:
  // 0=Purple, 1=Cyan, 2=Pink, 3=Lime, 4=Orange, 5=Grey

  static const _systemPrompt = '''
You are a creative personal growth coach. Your ONLY task is to output valid JSON and nothing else.

Output format (strict, no markdown, no explanation):
{"name":"<habit name max 4 words>","icon_index":<0-8>,"color_index":<0-5>}

Icon index meanings: 0=reading/book, 1=fitness/gym, 2=hydration/water, 3=coding/tech, 4=meditation/mindfulness, 5=sleep, 6=cycling/outdoors, 7=savings/finance, 8=art/creativity
Color index meanings: 0=purple, 1=cyan, 2=pink/red, 3=lime/green, 4=orange, 5=grey

Rules:
- Suggest diverse habits: learning, fitness, mindfulness, finance, creativity
- Habit name must be short (max 4 words), actionable, specific
- Pick the most fitting icon and a vibrant accent color (avoid grey unless it really fits)
- ONLY output the JSON object. No text before or after.
''';

  Future<void> suggestNewHabit() async {
    final apiKey = AppSecrets.geminiApiKey;

    if (apiKey.isEmpty || apiKey == 'PASTE_YOUR_API_KEY_HERE') {
      emit(const HabitSuggestionError('API key not configured.'));
      return;
    }

    emit(const HabitSuggestionLoading());

    try {
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
                {'role': 'system', 'content': _systemPrompt},
                {'role': 'user', 'content': 'Suggest a new habit for me.'},
              ],
              'temperature': 0.9,
              'max_tokens': 60,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('HabitSuggestion Groq Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText = data['choices'][0]['message']['content']
            .toString()
            .trim();

        // Strip possible markdown code fences if the model wraps in ```json
        final cleaned = rawText
            .replaceAll(RegExp(r'```[a-z]*'), '')
            .replaceAll('```', '')
            .trim();

        final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

        final name = (parsed['name'] as String?) ?? 'New Habit';
        final iconIndex = _clamp(parsed['icon_index'], 0, 8);
        final colorIndex = _clamp(parsed['color_index'], 0, 5);

        emit(
          HabitSuggestionLoaded(
            suggestedName: name,
            iconIndex: iconIndex,
            colorIndex: colorIndex,
          ),
        );
      } else {
        log('HabitSuggestion API Error: ${response.statusCode}');
        emit(
          const HabitSuggestionError(
            'Server error. Please try again in a moment.',
          ),
        );
      }
    } on FormatException catch (e) {
      log('HabitSuggestion JSON parse error: $e');
      emit(
        const HabitSuggestionError(
          'Could not read AI response. Tap ✨ to retry.',
        ),
      );
    } catch (e) {
      log('HabitSuggestion Unexpected error: $e');
      emit(const HabitSuggestionError('Network issue. Check your connection.'));
    }
  }

  void reset() => emit(const HabitSuggestionInitial());

  int _clamp(dynamic value, int min, int max) {
    if (value == null) return min;
    final i = (value as num).toInt();
    return i.clamp(min, max);
  }
}
