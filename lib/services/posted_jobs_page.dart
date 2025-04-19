import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostedJobsPage extends StatelessWidget {
  const PostedJobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Posted Jobs')),
      body: StreamBuilder<QuerySnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                .collection('Contractor')
                .doc(user.uid)
                .collection('Job Applications Post')
                .orderBy('timestamp', descending: true)
                .snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("You haven't posted any jobs yet."));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
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
                        Text(
                            "📅 Start: ${DateTime.tryParse(job['startDate'].toDate().toString())?.toLocal().toString().split(' ')[0] ?? ''}"),
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
