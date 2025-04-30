import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gig_connect/pages/view_profile_page.dart';

class JobApplicationsPage extends StatelessWidget {
  final String jobId;

  const JobApplicationsPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Applications'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .doc(jobId)
            .snapshots(),
        builder: (context, jobSnapshot) {
          if (jobSnapshot.hasError) {
            return Center(child: Text('Error: ${jobSnapshot.error}'));
          }

          if (jobSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobData = jobSnapshot.data?.data() as Map<String, dynamic>?;
          if (jobData == null) {
            return const Center(child: Text('Job not found'));
          }

          final applicants = jobData['applicants'] as List<dynamic>? ?? [];
          if (applicants.isEmpty) {
            return const Center(
              child: Text('No applications yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final applicantId = applicants[index];
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('worker_profiles')
                    .doc(applicantId)
                    .snapshots(),
                builder: (context, applicantSnapshot) {
                  if (applicantSnapshot.hasError) {
                    return const SizedBox.shrink();
                  }

                  if (applicantSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: LinearProgressIndicator(),
                    );
                  }

                  final applicantData =
                      applicantSnapshot.data?.data() as Map<String, dynamic>?;
                  if (applicantData == null) {
                    return const SizedBox.shrink();
                  }

                  final isSelected =
                      jobData['selectedApplicant'] == applicantId;
                  final isRejected =
                      (jobData['rejectedApplicants'] as List<dynamic>? ?? [])
                          .contains(applicantId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: null,
                            backgroundColor: Colors.purple,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            applicantData['username'] ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              applicantData['role'] ?? 'No role specified'),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : isRejected
                                  ? const Icon(Icons.cancel, color: Colors.red)
                                  : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProfilePage(
                                  userId: applicantId,
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Skills:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(applicantData['skills'] ??
                                  'No skills specified'),
                              const SizedBox(height: 8),
                              const Text(
                                'Experience:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(applicantData['experience'] ??
                                  'No experience specified'),
                            ],
                          ),
                        ),
                        if (!isSelected && !isRejected)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    // Reject application
                                    await FirebaseFirestore.instance
                                        .collection('jobs')
                                        .doc(jobId)
                                        .update({
                                      'rejectedApplicants':
                                          FieldValue.arrayUnion([applicantId])
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text('Reject'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Select applicant
                                    await FirebaseFirestore.instance
                                        .collection('jobs')
                                        .doc(jobId)
                                        .update({
                                      'selectedApplicants':
                                          FieldValue.arrayUnion([applicantId]),
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
