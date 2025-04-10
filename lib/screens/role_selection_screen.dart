// screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildRoleButton(
              context: context,
              role: 'worker',
              label: "I'm a Worker",
              color: Colors.blue[700]!,
            ),
            const SizedBox(height: 20),
            _buildRoleButton(
              context: context,
              role: 'recruiter',
              label: "I'm a Recruiter",
              color: Colors.green[700]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String role,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _setRole(context, role),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> _setRole(BuildContext context, String role) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileType': role,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),

      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error setting role: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}