import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'jods_application_page.dart';

class JobApplicationsListPage extends StatelessWidget {
  const JobApplicationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final jobs = snapshot.data!.docs;

          if (jobs.isEmpty) {
            return const Center(child: Text('You have not posted any jobs yet.'));
          }

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
