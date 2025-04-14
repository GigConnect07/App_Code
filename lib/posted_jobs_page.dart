import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostedJobsPage extends StatelessWidget {
  const PostedJobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your posted jobs.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posted Jobs'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('contractorId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You haven't posted any jobs yet."));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(job['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (job['location'] != null)
                        Text("📍 Location: ${job['location']}"),
                      if (job['paymentType'] != null &&
                          job['minRate'] != null &&
                          job['maxRate'] != null)
                        Text(
                            "💰 ${job['paymentType'] == 'hourly' ? 'Hourly' : 'Fixed'} Rate: ${job['minRate']} - ${job['maxRate']}"),
                      if (job['startDate'] != null)
                        Text("📅 Start: ${DateTime.tryParse(job['startDate'].toDate().toString())?.toLocal().toString().split(' ')[0] ?? ''}"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to job details or applicants (optional)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
