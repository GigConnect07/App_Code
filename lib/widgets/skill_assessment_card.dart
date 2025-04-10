// widgets/skill_assessment_card.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillAssessmentCard extends StatelessWidget {
  final String skill;

  const SkillAssessmentCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('assessments')
          .where('skill', isEqualTo: skill)
          .orderBy('date', descending: true)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return ElevatedButton(
            onPressed: () => _takeAssessmentTest(skill),
            child: const Text('Take Assessment Test'),
          );
        }

        final assessment = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return Chip(
          label: Text('Certified: ${assessment['score']}%'),
          backgroundColor: Colors.green[100],
          avatar: const Icon(Icons.verified, color: Colors.green),
        );
      },
    );
  }

  void _takeAssessmentTest(String skill) {
    // Implement assessment test flow
  }
}