import 'package:cloud_firestore/cloud_firestore.dart';

class JobPosting {
  final String id;
  final String company;
  final String contractorId;
  final String description;
  final String duration;
  final String experienceLevel;
  final String jobType;
  final String location;
  final String maxRate;
  final String minRate;
  final String paymentType;
  final String requirements;
  final List<String> skills;
  final DateTime startDate;
  final DateTime timestamp;
  final String title;

  JobPosting({
    required this.id,
    required this.company,
    required this.contractorId,
    required this.description,
    required this.duration,
    required this.experienceLevel,
    required this.jobType,
    required this.location,
    required this.maxRate,
    required this.minRate,
    required this.paymentType,
    required this.requirements,
    required this.skills,
    required this.startDate,
    required this.timestamp,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'contractorId': contractorId,
      'description': description,
      'duration': duration,
      'experienceLevel': experienceLevel,
      'jobType': jobType,
      'location': location,
      'maxRate': maxRate,
      'minRate': minRate,
      'paymentType': paymentType,
      'requirements': requirements,
      'skills': skills,
      'startDate': startDate,
      'timestamp': timestamp,
      'title': title,
    };
  }

  factory JobPosting.fromMap(Map<String, dynamic> map, String id) {
    // Handle skills field that could be either String or List
    List<String> skillsList = [];
    if (map['skills'] != null) {
      if (map['skills'] is String) {
        // If skills is a string, split it by comma and trim each item
        skillsList =
            (map['skills'] as String).split(',').map((e) => e.trim()).toList();
      } else if (map['skills'] is List) {
        // If skills is already a list, convert each item to string
        skillsList = (map['skills'] as List).map((e) => e.toString()).toList();
      }
    }

    return JobPosting(
      id: id,
      company: map['company'] ?? '',
      contractorId: map['contractorId'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      jobType: map['jobType'] ?? '',
      location: map['location'] ?? '',
      maxRate: map['maxRate'] ?? '',
      minRate: map['minRate'] ?? '',
      paymentType: map['paymentType'] ?? '',
      requirements: map['requirements'] ?? '',
      skills: skillsList,
      startDate: (map['startDate'] as Timestamp).toDate(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      title: map['title'] ?? '',
    );
  }
}
