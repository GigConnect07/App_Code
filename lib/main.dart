import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gig-Connect',
      theme: ThemeData(
        primaryColor: const Color(0xFFBA55D3),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFBA55D3),
        ),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}