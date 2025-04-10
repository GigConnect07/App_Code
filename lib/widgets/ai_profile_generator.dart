import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIProfileGenerator {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyStorageKey = 'sk-ec72baebd11945229cc199643da6f87e';

  static Future<String?> _getApiKey() async {
    return await _storage.read(key: _apiKeyStorageKey);
  }

  static Future<String> generateSuggestion({
    required String userId,
    required String section,
    required String currentContent,
    int maxRetries = 2,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not configured');
    }

    http.Response? response;
    Exception? lastError;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        response = await http.post(
          Uri.parse('https://api.deepseek.com/v1/suggestions'),
          headers: {
            'Authorization': 'Bearer sk-ec72baebd11945229cc199643da6f87e',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'user_id': userId,
            'section': section,
            'current_content': currentContent,
            'language': 'en',
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['suggestion'] ??
              data['response'] ??
              'No suggestion generated';
        } else if (response.statusCode == 401) {
          throw Exception('Invalid API key');
        } else {
          throw Exception(
              'API request failed with status ${response.statusCode}');
        }
      } on Exception catch (e) {
        lastError = e;
        if (attempt == maxRetries - 1) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    throw lastError ?? Exception('Unknown error occurred');
  }
}

class AISuggestionDialog extends StatefulWidget {
  final String userId;
  final String section;
  final String currentContent;
  final Function(String) onApply;
  final FirebaseFirestore firestore;

  const AISuggestionDialog({
    super.key,
    required this.userId,
    required this.section,
    required this.currentContent,
    required this.onApply,
    required this.firestore,
  });

  @override
  State<AISuggestionDialog> createState() => _AISuggestionDialogState();
}

class _AISuggestionDialogState extends State<AISuggestionDialog> {
  late Future<String> _suggestionFuture;
  String? _suggestion;

  @override
  void initState() {
    super.initState();
    _suggestionFuture = _generateSuggestion();
  }

  Future<String> _generateSuggestion() async {
    try {
      final suggestion = await AIProfileGenerator.generateSuggestion(
        userId: widget.userId,
        section: widget.section,
        currentContent: widget.currentContent,
      );
      setState(() => _suggestion = suggestion);
      return suggestion;
    } catch (e) {
      throw Exception('Failed to generate suggestion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Suggestion'),
      content: FutureBuilder<String>(
        future: _suggestionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            );
          }
          return SingleChildScrollView(
            child: Text(snapshot.data ?? 'No suggestion available'),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _suggestion != null
              ? () {
            widget.onApply(_suggestion!);
            Navigator.pop(context);
          }
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

// Usage example in ProfileScreen
class ProfileScreenHelper {
  final BuildContext context;
  final FirebaseFirestore firestore;
  final Map<String, dynamic>? userData;
  final VoidCallback loadUserData;

  ProfileScreenHelper({
    required this.context,
    required this.firestore,
    required this.userData,
    required this.loadUserData,
  });

  Future<void> handleAISuggestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final suggestion = await showDialog<String>(
      context: context,
      builder: (context) => AISuggestionDialog(
        userId: user.uid,
        section: 'bio',
        currentContent: userData?['bio'] ?? '',
        onApply: (suggestion) async {
          await firestore.collection('users').doc(user.uid).update({
            'bio': suggestion,
            'last_updated': FieldValue.serverTimestamp(),
          });
          loadUserData();
        },
        firestore: firestore,
      ),
    );

    if (suggestion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated with AI suggestion')),
      );
    }
  }
}