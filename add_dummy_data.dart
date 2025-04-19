import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseDataHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add dummy user to 'users' collection
  Future<void> addDummyUser() async {
    try {
      await _firestore.collection('users').doc('user_001').set({
        'uid': 'user_001',
        'name': 'Rahul Sharma',
        'email': 'rahul@example.com',
        'phone': '+919876543210',
        'city': 'Mumbai',
        'pinCode': '400001',
        'skills': {
          'Electrician': ['Wiring', 'Circuit Repair'],
          'Plumber': ['Pipe Installation']
        },
        'userType': 'worker',
        'createdAt': FieldValue.serverTimestamp(),
        'hourlyRate': 450,
        'availability': 'Full-time',
        'certificates': ['ITI Electrical', 'Safety Training'],
        'profileImage': 'https://example.com/user1.jpg',
        'about': 'Experienced electrician with 5+ years of experience',
      });
      print('Dummy user added successfully!');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  // Add dummy contractor to 'contractors' collection
  Future<void> addDummyContractor() async {
    try {
      await _firestore.collection('contractors').doc('contractor_001').set({
        'contractorId': 'contractor_001',
        'companyName': 'Mumbai Builders Corp.',
        'email': 'contact@mumbaibuilders.com',
        'phone': '+912234567890',
        'location': 'Andheri East, Mumbai',
        'industry': 'Construction',
        'jobPostings': ['Site Supervisor', 'Masonry Specialist'],
        'rating': 4.7,
        'projectsCompleted': 32,
        'establishedYear': 2015,
        'website': 'https://mumbaibuilders.com',
        'companyLogo': 'https://example.com/contractor-logo.png',
      });
      print('Dummy contractor added successfully!');
    } catch (e) {
      print('Error adding contractor: $e');
    }
  }

  // Initialize Firebase and add both dummy records
  Future<void> initializeAndAddData() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await addDummyUser();
    await addDummyContractor();
  }
}

// Temporary button to trigger data addition (Add to any screen)
class DataAdditionButton extends StatelessWidget {
  final FirebaseDataHelper _dataHelper = FirebaseDataHelper();

  DataAdditionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await _dataHelper.initializeAndAddData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dummy data added to Firestore!')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text(
        'Add Demo Data',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}