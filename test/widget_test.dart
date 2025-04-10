import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:final5/widgets/edit_section_dialog.dart'; // Import your actual dialog widget

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFile extends Mock implements File {
  @override
  Future<int> length() => super.noSuchMethod(Invocation.method(#length, []),
      returnValue: Future.value(0)) as Future<int>;
}

void main() {
  testWidgets('Edit Section Dialog Test', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EditSectionDialog(
          title: 'Bio',
          initialValue: 'Test bio',
          fieldName: 'bio',
        ),
      ),
    ));

    expect(find.text('Edit Bio'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'New bio');
    await tester.tap(find.text('Save'));
    await tester.pump();
  });

  test('Image Size Validation Test', () async {
    final mockFile = MockFile();
    when(mockFile.length()).thenAnswer((_) async => 6 * 1024 * 1024);

    // Assuming validateImageSize is a function you've imported
    expect(validateImageSize(mockFile), throwsException);
  });
}

// Add this if validateImageSize isn't imported from another file
bool validateImageSize(File file) {
  // Your actual validation logic
  return file.lengthSync() > 5 * 1024 * 1024;
}