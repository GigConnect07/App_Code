import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authSnapshot.hasData) {
            final user = authSnapshot.data!;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profileSnapshot.hasError) {
                  return Center(child: Text("Something went wrong: ${profileSnapshot.error}"));
                }

                if (profileSnapshot.hasData && profileSnapshot.data!.exists) {
                  // If profile exists in Firestore, go to Contractor Main Screen
                  return const ContractorMainScreen();
                } else {
                  // If profile doesn't exist, show registration page
                  return RegistrationPage(); // FIXED HERE
                }
              },
            );
          }

          // If no user is signed in, show the Auth screen
          return const AuthScreen();
        },
      ),
      routes: {
        '/profile': (context) => const ContractorProfilePage(),
        '/postJob': (context) => const PostJobPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/contractor-home': (context) => const ContractorMainScreen(), // ADDED THIS ROUTE
      },
    );
  }
}