import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/registration_page.dart'; // Make sure this is the correct path

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitAuthForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // Login Flow
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigate to contractor home page after successful login
        Navigator.pushReplacementNamed(context, '/contractor-home');
      } else {
        // Registration Flow
        final credential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (credential.user != null) {
          // Navigate to registration screen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegistrationPage(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    }

    setState(() => _isLoading = false);
  }

  void _toggleForm() => setState(() {
    _isLogin = !_isLogin;
    _errorMessage = null;
  });

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? 'Login to Your Account' : 'Create an Account';
    final buttonText = _isLogin ? 'Login' : 'Continue';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.engineering_rounded, size: 72, color: Colors.blue.shade700),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitAuthForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(buttonText),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: _toggleForm,
                child: Text(
                  _isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
