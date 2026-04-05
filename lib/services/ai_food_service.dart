import 'dart:convert';
import 'dart:developer';
import 'package:ai_calorie_counter/constants.dart';
import 'package:http/http.dart' as http;

class AIFoodService {
  static Future<Map<String, dynamic>> analyzeFood(String input) async {
    final url = "https://api.groq.com/openai/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${Constants.API_KEY2}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "system",
              "content":
                  '''You are a nutrition assistant. Extract food items and return calories and macros in a clean JSON format.
                  
If the input is FOOD, return:
{
  "type": "meal",
  "items": [
    {
      "name": "food name",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fat": number
    }
  ],
  "totals": {
    "calories": number,
    "protein": number,
    "carbs": number,
    "fat": number
  }
}

If the input is EXERCISE, return:
{
  "type": "exercise",
  "activity": "exercise name",
  "duration_minutes": number,
  "calories_burned": number
}

Only JSON.
No explanation.
No markdown.''',
            },
            {"role": "user", "content": input},
          ],
          "temperature": 0.2,
        }),
      );

      // final data = jsonDecode(response.body);
      // log("Gemini response: $data");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final content = data['choices'][0]['message']['content'];
        final cleaned = content
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();

        return jsonDecode(cleaned);
      } else {
        log('this is a error in the API Call............');
        throw Exception("Groq API error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Groq failed: $e");
    }
  }
}
