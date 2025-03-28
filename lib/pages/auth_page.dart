
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/pages/home_page.dart';
import 'package:gig_connect/pages/login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder:(context, snapshot) {
        //if user is logged in
        if (snapshot.hasData) {
          return HomePage();
        }
        //if user not logged in
        else{
          return LoginOrRegisterPage();
        }
      }, ),
    );
  }
}