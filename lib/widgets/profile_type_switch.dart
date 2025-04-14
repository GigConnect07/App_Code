
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileTypeSwitch extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback loadUserData;
  final FirebaseFirestore firestore;
  final User? user; 

  const ProfileTypeSwitch({
    super.key,
    required this.userData,
    required this.loadUserData,
    required this.firestore,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Recruiter Mode'),
      subtitle: const Text('Switch between worker and recruiter views'),
      value: userData?['profileType'] == 'recruiter',
      onChanged: (value) async {
        try {
          if (user == null) return;

          await firestore.collection('users').doc(user!.uid).update({
            'profileType': value ? 'recruiter' : 'worker',
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          loadUserData();

          // Optional: Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${value ? 'Recruiter' : 'Worker'} mode'),
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update mode: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}