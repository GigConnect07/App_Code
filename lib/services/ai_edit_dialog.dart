import 'package:flutter/material.dart';

class AIEditDialog {
  static Future<String?> show({
    required BuildContext context,
    required String sectionName,
    required String currentContent,
  }) async {
    final promptController = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AI Edit $sectionName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Content: $currentContent'),
            const SizedBox(height: 16),
            TextField(
              controller: promptController,
              decoration: const InputDecoration(
                labelText: 'Your edit instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, promptController.text),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}