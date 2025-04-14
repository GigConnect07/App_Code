// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../error_handler.dart';
// import '../widgets/keyboard_visibility_detector.dart';
//
// @override
//
//
// class RegisterScreen extends StatelessWidget {
//   RegisterScreen({super.key});
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   Future<void> _register() async {
//     try {
//       final UserCredential credential = await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       // Navigate to role selection screen
//       if (credential.user != null) {
//         Navigator.pushReplacementNamed(context, '/role-selection');
//       }
//     } on FirebaseAuthException catch (e) {
//       ErrorHandler.showAuthError(e.code);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const KeyboardVisibilityDetector(),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _register,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFBA55D3),
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//               ),
//               child: const Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }