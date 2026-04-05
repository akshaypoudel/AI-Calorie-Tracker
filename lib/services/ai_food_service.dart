import 'dart:convert';
import 'dart:developer';
import 'package:ai_calorie_counter/constants.dart';
import 'package:http/http.dart' as http;

class AIFoodService {
  static Future<Map<String, dynamic>> analyzeFood(String input) async {
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${Constants.API_KEY}";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    '''
Analyze the input and return ONLY valid JSON.

Input: $input

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
No markdown.

                ''',
              },
            ],
          },
        ],
      }),
    );

    final data = jsonDecode(response.body);
    log("Gemini response: $data");

    try {
      final text = data["candidates"][0]["content"]["parts"][0]["text"];
      return jsonDecode(text);
    } catch (e) {
      return {};
    }
  }
}
