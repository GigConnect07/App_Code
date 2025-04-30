import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/pages/job_details_page.dart';
import 'package:gig_connect/pages/chat_page.dart';

class AppliedJobsPage extends StatelessWidget {
  const AppliedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applied Jobs')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('applicants', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data?.docs ?? [];
          if (jobs.isEmpty) {
            return const Center(
              child: Text('You have not applied to any jobs yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final jobData = job.data() as Map<String, dynamic>;

              // Get job status
              final List<dynamic> selectedApplicants =
                  jobData['selectedApplicants'] as List<dynamic>? ?? [];
              final List<dynamic> rejectedApplicants =
                  jobData['rejectedApplicants'] as List<dynamic>? ?? [];
              final bool isSelected =
                  selectedApplicants.contains(currentUser.uid);
              final bool isRejected =
                  rejectedApplicants.contains(currentUser.uid);

              // Get status color and text
              Color statusColor;
              String statusText;
              IconData statusIcon;

              if (isSelected) {
                statusColor = Colors.green;
                statusText = 'Selected';
                statusIcon = Icons.check_circle;
              } else if (isRejected) {
                statusColor = Colors.red;
                statusText = 'Rejected';
                statusIcon = Icons.cancel;
              } else {
                statusColor = Colors.orange;
                statusText = 'Pending';
                statusIcon = Icons.pending;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailsPage(
                          jobId: job.id,
                          jobData: jobData,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                jobData['title'] ?? 'Untitled Job',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon,
                                      color: statusColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          jobData['description'] ?? 'No description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(jobData['location'] ??
                                'Location not specified'),
                            const SizedBox(width: 16),
                            const Icon(Icons.attach_money, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '\$${jobData['minRate'] ?? '0'} - \$${jobData['maxRate'] ?? '0'}',
                            ),
                          ],
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        receiverEmail:
                                            jobData['contractorEmail'] ??
                                                'Unknown User',
                                        receiverID: jobData['contractorId'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text('Chat with Contractor'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (!isSelected && !isRejected) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // Show confirmation dialog
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Withdraw Application'),
                                      content: const Text(
                                          'Are you sure you want to withdraw your application?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Withdraw',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      // Remove user from applicants list
                                      await FirebaseFirestore.instance
                                          .collection('jobs')
                                          .doc(job.id)
                                          .update({
                                        'applicants': FieldValue.arrayRemove(
                                            [currentUser.uid]),
                                      });

                                      // Delete the notification for the contractor
                                      final notifications =
                                          await FirebaseFirestore.instance
                                              .collection('notifications')
                                              .where('jobId', isEqualTo: job.id)
                                              .where('workerId',
                                                  isEqualTo: currentUser.uid)
                                              .where('type',
                                                  isEqualTo: 'new_application')
                                              .get();

                                      for (var notification
                                          in notifications.docs) {
                                        await notification.reference.delete();
                                      }

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Application withdrawn successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error withdrawing application: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text('Withdraw Application'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
