// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GigUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String pinCode;
  final String? business;
  final Map<String, List<String>> skills;
  final String userType;
  final DateTime createdAt;
  final String authEmail;

  GigUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.authEmail,
    required this.phone,
    required this.city,
    required this.pinCode,
    this.business,
    required this.skills,
    required this.userType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return // users collection
      {
        'authEmail': authEmail,
        'uid': 'string',
        'name': 'string',
        'email': 'string',
        'profileImage': 'string',
        'coverImage': 'string',
        'about': 'string',
        'skills': ['string'],
        'industries': [
          {
            'name': 'string',
            'description': 'string'
          }
        ],
        'userType': 'worker|recruiter',
        'createdAt': Timestamp,
        'hourlyRate': 'number',
        'pinCode' : 'number',
        'availability': 'string',
        'certificates': ['string']
      };
  }
}