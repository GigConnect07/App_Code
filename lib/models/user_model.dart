// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GigUser {
  final String uid;
  final String name;
  final String email;
  final String authEmail;
  final String phone;
  final String city;
  final String pinCode;
  final String? business;
  final Map<String, List<String>> skills;
  final String userType;
  final DateTime createdAt;
  final int hourlyRate;
  final String availability;

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
    required this.hourlyRate,
    required this.availability,
  });

  // Add this factory constructor
  factory GigUser.fromMap(Map<String, dynamic> data) {
    return GigUser(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      authEmail: data['authEmail'],
      phone: data['phone'],
      city: data['city'],
      pinCode: data['pinCode'],
      business: data['business'],
      skills: Map<String, List<String>>.from(data['skills']),
      userType: data['userType'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      hourlyRate: data['hourlyRate'],
      availability: data['availability'],
    );
  }
}

// models/user_model.dart
class Contractor {
  final String contractorId;
  final String companyName;
  final String email;
  final String phone;
  final String location;
  final String industry;
  final List<String> jobPostings;
  final double rating;
  final int projectsCompleted;

  Contractor({
    required this.contractorId,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.location,
    required this.industry,
    required this.jobPostings,
    required this.rating,
    required this.projectsCompleted,
  });

  // Factory constructor to deserialize Firestore data
  factory Contractor.fromMap(Map<String, dynamic> data) {
    return Contractor(
      contractorId: data['contractorId'],
      companyName: data['companyName'],
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
      industry: data['industry'],
      jobPostings: List<String>.from(data['jobPostings']),
      rating: data['rating'].toDouble(),
      projectsCompleted: data['projectsCompleted'],
    );
  }
}