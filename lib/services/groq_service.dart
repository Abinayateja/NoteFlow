import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> askGroq(String text) async {
  const groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  final response = await http.post(
    Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
    headers: {
      "Authorization": "Bearer ${groqApiKey}",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "model": "llama-3.3-70b-versatile",
      "messages": [
        {
          "role":"system",
          "content":"You are a mood classifier. Only reply with ONE word from this list: relax, focus, happy, love."
        },
        {
          "role":"user",
          "content":"Classify the mood of this music request: $text"
        }
      ]
    }),
  ); 

  final data = jsonDecode(response.body);

  print("API RESPONSE: $data");

  if(data["choices"] != null){

    return data["choices"][0]["message"]["content"]
        .toString()
        .toLowerCase()
        .trim();
  }

  return "happy"; // fallback mood
}