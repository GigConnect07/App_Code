import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure you have the Cloud Firestore package

// Screens
import 'auth_screen.dart';
import 'registration_page.dart';
import 'contractor_main_screen.dart';
import 'contractor_profile_page.dart';
import 'post_job_page.dart';
import 'notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contractor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            // Check if the user exists in Firestore (i.e., profile is completed)
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid) // Get the user doc using UID
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  // If user document exists, navigate to the main screen
                  return const ContractorMainScreen();
                } else {
                  // If user document does not exist, navigate to the registration page
                  return RegistrationPage();
                }
              },
            );
          }

          // If user is not logged in, show the auth screen
          return const AuthScreen();
        },
      ),
      routes: {
        '/profile': (context) => const ContractorProfilePage(),
        '/postJob': (context) => const PostJobPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}
