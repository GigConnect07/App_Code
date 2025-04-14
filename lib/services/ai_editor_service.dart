import 'dart:convert';
import 'package:http/http.dart' as http;

class AIEditorService {
  static const String _baseUrl = 'https://api.deepseek.com/v1';
  final String apiKey;

  AIEditorService({required this.apiKey});

  Future<String> generateEdit({
    required String sectionName,
    required String currentContent,
    required String userPrompt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sk-e9ec1f3394b34704be58dce0a353c49c',
        },
        body: jsonEncode({
          'messages': [
            {
              'role': 'system',
              'content': '''You are a professional profile editor. 
              Current $sectionName section content: $currentContent.
              User wants to modify it with this instruction:''',
            },
            {'role': 'user', 'content': userPrompt}
          ],
          'model': 'deepseek-chat',
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      throw Exception('API Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to generate edit: $e');
    }
  }
}