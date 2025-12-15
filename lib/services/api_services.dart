import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  static const String _baseUrl = "https://your-backend-url.com/chat";

  static Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['reply'];
    }

    if (response.statusCode == 429) {
      return "You're sending messages too fast. Please wait a moment.";
    }

    return "Something went wrong. Please try again.";
  }
}
