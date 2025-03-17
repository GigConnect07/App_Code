
import 'package:flutter/material.dart';
import 'package:gig_connect/pages/login_page.dart';
import 'package:gig_connect/pages/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  //initially show Login Page
  bool showLoginPage=true;

  //toggle btn login and register page
  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage==true) {
      return LoginPage(onTap: togglePages);
    }
    else{
      return RegisterPage(onTap: togglePages,);
    }
  }
}