import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class APIService {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyStorageKey = 'sk-ec72baebd11945229cc199643da6f87e';


  static Future<void> storeApiKey(String key) async {
    if (key.isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }
    await _storage.write(key: _apiKeyStorageKey, value: key);
  }

  // Retrieve API key
  static Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyStorageKey);
  }

  static Future<String> generateAISuggestion(
      String userId,
      String userBio,
      ) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found');
      }

      final response = await http.post(
        Uri.parse('https://api.deepseek.com/v1/suggestions'),
        headers: {
          'Authorization': 'Bearer sk-ec72baebd11945229cc199643da6f87e',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'context': userBio,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['suggestion'] ?? 'No suggestion available';
      } else {
        throw Exception(
            'Failed to get suggestion: ${response.statusCode} - ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Failed to generate suggestion: $e');
    }
  }
}