import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:foodapp/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';



class GPT3 {
  static Future<String> generateText(String prompt) async {
    String model = "gpt-3.5-turbo";
    final gptApiKey = await fetchChatGptData();
// 전역 변수 사용
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $gptApiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 1000,
        'temperature': 0.5,
      }),
    );

    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedBody);
      return data['choices'][0]['message']['content'].trim();
    } else {
      return "Error: ${response.reasonPhrase}";
    }
  }
}
