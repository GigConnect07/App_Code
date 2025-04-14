import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/pages/contractor_page.dart';
import 'package:gig_connect/pages/home_screen.dart';

class DirectingPage extends StatefulWidget {
  const DirectingPage({super.key});

  @override
  _DirectingPageState createState() => _DirectingPageState();
}

class _DirectingPageState extends State<DirectingPage> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestore ka reference
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userRole = userDoc['role'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return userRole == "Worker" ? HomePageScreen() : ContractorPage();
  }
}
