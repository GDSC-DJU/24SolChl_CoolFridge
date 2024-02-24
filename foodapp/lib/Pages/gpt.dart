import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class GPT3 {
  static Future<String> generateText(String prompt) async {
    String model = "gpt-3.5-turbo";
    final gptApiKey = Platform.environment['OPENAI_API_KEY'];
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

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      //  print('Decoded response body: $decodedBody');
      var data = jsonDecode(decodedBody);
      String answer = data['choices'][0]['message']['content'].trim();
      //  print(answer);
      return data['choices'][0]['message']['content'].trim();
    } else {
      return "Error: ${response.reasonPhrase}";
    }
  }
}
