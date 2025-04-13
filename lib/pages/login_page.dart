
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/components/my_button.dart';
import 'package:gig_connect/components/my_textfield.dart';
import 'package:gig_connect/components/square_tile.dart';
import 'package:gig_connect/pages/directing_page.dart';
import 'package:gig_connect/pages/phone_login.dart';
import 'package:gig_connect/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUserIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        default:
          errorMessage = 'Login failed. Please try again';
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 50),
              const Center(
                child: Icon(
                  Icons.account_balance,
                  size: 100,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Welcome To Our App',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              MyTextfield(
                label: 'Email',
                controller: emailController,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              MyTextfield(
                label: 'Password',
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // TODO: Add password reset
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: _isLoading ? null : () => _signUserIn(context),
                text: 'Sign In',
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const Expanded(child: Divider(thickness: 0.5)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(
                    imagepath: 'lib/images/download_transparent.png',
                    onTap: _isLoading
                        ? null
                        : () async {
            try {
              final userCred = await AuthService().signInWithGoogle();
              
              if (userCred.user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DirectingPage()),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login failed: $e")),
              );
            }
                          },
                  ),
                  const SizedBox(width: 20),
                  SquareTile(
                    imagepath: 'lib/images/phone.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpVerify(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
