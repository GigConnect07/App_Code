import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplicationsPage extends StatelessWidget {
  final String jobId;
  final String jobTitle;
  final String contractorId;

  const JobApplicationsPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.contractorId,
  });

  Future<void> _updateApplicationStatus(
      Map<String, dynamic> applicant, String newStatus) async {
    try {
      final updatedApplicant = {...applicant, 'status': newStatus};

      await FirebaseFirestore.instance
          .collection('Contractor')
          .doc(contractorId)
          .collection('Job Applications Post')
          .doc(jobId)
          .update({
        'applicants': FieldValue.arrayRemove([applicant]),
        'applicants': FieldValue.arrayUnion([updatedApplicant])
      });
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Applications for $jobTitle")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Contractor')
            .doc(contractorId)
            .collection('Job Applications Post')
            .doc(jobId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final List<dynamic> applicants = data['applicants'] ?? [];

          if (applicants.isEmpty) {
            return const Center(child: Text("No applications yet."));
          }

          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final applicant = applicants[index];
              final status = applicant['status'] ?? 'pending';
              final skills = List<String>.from(applicant['skills'] ?? []);
              final applicantId = applicant['applicantId'] ?? '';

              return JobApplicationCard(
                applicant: applicant,
                skills: skills,
                status: status,
                onAccept: () => _updateApplicationStatus(applicant, 'accepted'),
                onReject: () => _updateApplicationStatus(applicant, 'rejected'),
              );
            },
          );
        },
      ),
    );
  }
}

class JobApplicationCard extends StatelessWidget {
  final Map<String, dynamic> applicant;
  final List<String> skills;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const JobApplicationCard({
    super.key,
    required this.applicant,
    required this.skills,
    required this.status,
    required this.onAccept,
    required this.onReject,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending Review';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text('${applicant['name'] ?? 'Applicant'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(applicant['location'] ?? 'Location not specified'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6.0,
              children:
                  skills.map((skill) => Chip(label: Text(skill))).toList(),
            ),
            const SizedBox(height: 6),
            Text(
                'Applied: ${(applicant['dateApplied'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'N/A'}'),
            Text(
              _getStatusText(),
              style: TextStyle(
                  color: _getStatusColor(), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {},
            ),
            if (status == 'pending') ...[
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: onAccept,
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: onReject,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
