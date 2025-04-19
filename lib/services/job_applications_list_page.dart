import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'jobs_application_page.dart'; // Ensure correct file name

class JobApplicationsListPage extends StatelessWidget {
  const JobApplicationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view job applications')),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Contractor')
            .doc(user.uid)
            .collection('Job Applications Post')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No jobs posted yet'));
          }

          final jobs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final jobData = job.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(jobData['title'] ?? 'Untitled Job'),
                subtitle: Text(jobData['description'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobApplicationsPage(
                        jobId: job.id,
                        jobTitle: jobData['title'] ?? 'Job',
                        contractorId: user.uid, // Add this parameter
                      ),
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
