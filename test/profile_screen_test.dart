import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final5/screens/profile_screen.dart'; // Adjust import path

// Mock classes using mockito
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
class MockUser extends Mock implements User {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockDocumentSnapshot mockSnapshot;
  late MockUser mockUser;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();
    mockUser = MockUser();
    mockAuth = MockFirebaseAuth();

    // Setup mockito stubs
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection as CollectionReference<Map<String, dynamic>>);
    when(mockUsersCollection.doc('test_uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.get()).thenAnswer((_) async => mockSnapshot);
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_uid');
  });

  testWidgets('Profile displays loading state', (tester) async {
    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.data()).thenReturn({});

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(firestore: mockFirestore, auth: mockAuth),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Profile displays user data when loaded', (tester) async {
    final testData = {
      'name': 'Test User',
      'profileType': 'worker',
      'skills': ['Flutter', 'Firebase'],
    };

    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.data()).thenReturn(testData);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(firestore: mockFirestore, auth: mockAuth),
      ),
    );

    await tester.pump(); // Wait for data to load

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Flutter • Firebase'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}