import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/pages/job_details_page.dart';
import 'package:gig_connect/pages/view_profile_page.dart';
import 'package:gig_connect/pages/chat_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('Not logged in'),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Applications'),
                Tab(text: 'Invite Responses'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Applications Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .where('contractorId', isEqualTo: currentUser.uid)
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
                    child: Text('No job applications yet'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    final jobData = job.data() as Map<String, dynamic>;
                    final applicants =
                        jobData['applicants'] as List<dynamic>? ?? [];
                    final selectedApplicants =
                        jobData['selectedApplicants'] as List<dynamic>? ?? [];
                    final rejectedApplicants =
                        jobData['rejectedApplicants'] as List<dynamic>? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: selectedApplicants.isNotEmpty
                              ? Colors.green
                              : Colors.blue,
                          child: Icon(
                            selectedApplicants.isNotEmpty
                                ? Icons.check_circle
                                : Icons.people,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          jobData['title'] ?? 'Untitled Job',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedApplicants.isNotEmpty
                                  ? '${selectedApplicants.length} worker${selectedApplicants.length == 1 ? '' : 's'} selected'
                                  : '${applicants.length} ${applicants.length == 1 ? 'application' : 'applications'}',
                            ),
                            Text(
                              'Posted on: ${DateTime.now().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        children: [
                          ...applicants.map((applicantId) {
                            final isSelected =
                                selectedApplicants.contains(applicantId);
                            final isRejected =
                                rejectedApplicants.contains(applicantId);

                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('worker_profiles')
                                  .doc(applicantId)
                                  .snapshots(),
                              builder: (context, workerSnapshot) {
                                if (!workerSnapshot.hasData) {
                                  return const ListTile(
                                    title: Text('Loading...'),
                                  );
                                }

                                final workerData = workerSnapshot.data?.data()
                                        as Map<String, dynamic>? ??
                                    {};

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? Colors.green
                                        : isRejected
                                            ? Colors.red
                                            : Colors.blue,
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : isRejected
                                              ? Icons.cancel
                                              : Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                      workerData['username'] ?? 'Unknown User'),
                                  subtitle: Text(workerData['role'] ??
                                      'No role specified'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isSelected && !isRejected)
                                        IconButton(
                                          icon: const Icon(Icons.check,
                                              color: Colors.green),
                                          onPressed: () async {
                                            try {
                                              // First update the job with the new selected applicant
                                              await FirebaseFirestore.instance
                                                  .collection('jobs')
                                                  .doc(job.id)
                                                  .update({
                                                'selectedApplicants':
                                                    FieldValue.arrayUnion(
                                                        [applicantId]),
                                              });

                                              // Get the worker's profile data for the notification
                                              final workerDoc =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'worker_profiles')
                                                      .doc(applicantId)
                                                      .get();
                                              final workerData =
                                                  workerDoc.data() ??
                                                      {};

                                              // Create notification for the worker
                                              await FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .add({
                                                'workerId': applicantId,
                                                'jobId': job.id,
                                                'jobTitle': jobData['title'],
                                                'contractorId': currentUser.uid,
                                                'type': 'application_response',
                                                'status': 'accepted',
                                                'message':
                                                    'Your application for ${jobData['title']} has been accepted!',
                                                'createdAt': FieldValue
                                                    .serverTimestamp(),
                                                'read': false,
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Application accepted successfully!'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error accepting application: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      if (!isSelected && !isRejected)
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () async {
                                            try {
                                              // First update the job with the rejected applicant
                                              await FirebaseFirestore.instance
                                                  .collection('jobs')
                                                  .doc(job.id)
                                                  .update({
                                                'rejectedApplicants':
                                                    FieldValue.arrayUnion(
                                                        [applicantId]),
                                              });

                                              // Get the worker's profile data for the notification
                                              final workerDoc =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'worker_profiles')
                                                      .doc(applicantId)
                                                      .get();
                                              final workerData =
                                                  workerDoc.data() ??
                                                      {};

                                              // Create notification for the worker
                                              await FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .add({
                                                'workerId': applicantId,
                                                'jobId': job.id,
                                                'jobTitle': jobData['title'],
                                                'contractorId': currentUser.uid,
                                                'type': 'application_response',
                                                'status': 'rejected',
                                                'message':
                                                    'Your application for ${jobData['title']} has been rejected.',
                                                'createdAt': FieldValue
                                                    .serverTimestamp(),
                                                'read': false,
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Application rejected successfully!'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error rejecting application: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.person),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewProfilePage(
                                                userId: applicantId,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (isSelected)
                                        IconButton(
                                          icon: const Icon(Icons.chat,
                                              color: Colors.deepPurpleAccent),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  receiverEmail:
                                                      workerData['email'] ??
                                                          'Unknown User',
                                                  receiverID: applicantId,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Invite Responses Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('contractorId', isEqualTo: currentUser.uid)
                  .where('type', isEqualTo: 'invite_response')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = snapshot.data?.docs ?? [];
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('No invite responses yet'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final notificationData =
                        notification.data() as Map<String, dynamic>;
                    final jobId = notificationData['jobId'];
                    final jobTitle = notificationData['jobTitle'];
                    final status = notificationData['status'];
                    final workerId = notificationData['workerId'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: status == 'accepted'
                              ? Colors.green
                              : status == 'rejected'
                                  ? Colors.red
                                  : Colors.blue,
                          child: Icon(
                            status == 'accepted'
                                ? Icons.check_circle
                                : status == 'rejected'
                                    ? Icons.cancel
                                    : Icons.pending,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(jobTitle ?? 'Unknown Job'),
                        subtitle: Text(
                          status == 'accepted'
                              ? 'Worker accepted your invite'
                              : 'Worker declined your invite',
                        ),
                        children: [
                          // Job Description Section
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('jobs')
                                .doc(jobId)
                                .snapshots(),
                            builder: (context, jobSnapshot) {
                              if (!jobSnapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Loading job details...'),
                                );
                              }

                              final jobData = jobSnapshot.data?.data()
                                  as Map<String, dynamic>?;
                              if (jobData == null) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Job not found'),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Job Description',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(jobData['description'] ??
                                        'No description available'),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Job Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Location: ${jobData['location'] ?? 'Not specified'}'),
                                    Text(
                                        'Payment Type: ${jobData['paymentType'] ?? 'Not specified'}'),
                                    Text(
                                        'Duration: ${jobData['duration'] ?? 'Not specified'}'),
                                    Text(
                                        'Rate: ₹${jobData['minRate'] ?? '0'} - ₹${jobData['maxRate'] ?? '0'}'),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Worker Profile Section
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('worker_profiles')
                                .doc(workerId)
                                .snapshots(),
                            builder: (context, workerSnapshot) {
                              if (!workerSnapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Loading worker profile...'),
                                );
                              }

                              final workerData = workerSnapshot.data?.data()
                                  as Map<String, dynamic>?;
                              if (workerData == null) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Worker profile not found'),
                                );
                              }

                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Worker Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: null,
                                          backgroundColor: Colors.purple,
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                workerData['username'] ??
                                                    'Unknown Worker',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                workerData['role'] ??
                                                    'No role specified',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (workerData['skills'] != null &&
                                        workerData['skills'] is List) ...[
                                      const Text(
                                        'Skills',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: (workerData['skills']
                                                as List<dynamic>)
                                            .map((skill) => Chip(
                                                  label: Text(skill.toString()),
                                                  backgroundColor: Colors.blue
                                                      .withOpacity(0.2),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                    if (workerData['experience'] != null) ...[
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Experience',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(workerData['experience']),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (status == 'accepted')
                                  IconButton(
                                    icon: const Icon(Icons.chat,
                                        color: Colors.deepPurpleAccent),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            receiverEmail: notificationData[
                                                    'workerEmail'] ??
                                                'Unknown User',
                                            receiverID: workerId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobDetailsPage(
                                          jobId: jobId,
                                          jobData: notificationData,
                                        ),
                                      ),
                                    );
                                  },
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
            ),
          ],
        ),
      ),
    );
  }
}
