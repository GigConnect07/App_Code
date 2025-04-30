import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/pages/job_details_page.dart';
import 'package:gig_connect/models/worker_profile.dart';
import 'package:gig_connect/services/worker_profile_service.dart';
import 'package:gig_connect/pages/chat_page.dart';
import 'package:gig_connect/pages/job_invite_details_page.dart';

class WorkerNotificationsPage extends StatefulWidget {
  const WorkerNotificationsPage({super.key});

  @override
  State<WorkerNotificationsPage> createState() =>
      _WorkerNotificationsPageState();
}

class _WorkerNotificationsPageState extends State<WorkerNotificationsPage> {
  final WorkerProfileService _profileService = WorkerProfileService();
  WorkerProfile? _workerProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.getWorkerProfile();
    if (mounted) {
      setState(() {
        _workerProfile = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Notifications')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notifications'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Applications'),
                Tab(text: 'Invites'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Applications Tab
                  StreamBuilder<QuerySnapshot>(
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
                          child: Text('No job applications yet'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          final jobData = job.data() as Map<String, dynamic>;
                          final List<dynamic> selectedApplicants =
                              jobData['selectedApplicants'] as List<dynamic>? ??
                                  [];
                          final isSelected =
                              selectedApplicants.contains(currentUser.uid);
                          final isRejected = (jobData['rejectedApplicants']
                                      as List<dynamic>? ??
                                  [])
                              .contains(currentUser.uid);

                          IconData statusIcon;
                          Color statusColor;
                          String statusText;

                          if (isSelected) {
                            statusIcon = Icons.check_circle;
                            statusColor = Colors.green;
                            statusText = 'Application Accepted';
                          } else if (isRejected) {
                            statusIcon = Icons.cancel;
                            statusColor = Colors.red;
                            statusText = 'Application Rejected';
                          } else {
                            statusIcon = Icons.pending;
                            statusColor = Colors.blue;
                            statusText = 'Application Pending';
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor,
                                child: Icon(statusIcon, color: Colors.white),
                              ),
                              title: Text(
                                jobData['title'] ?? 'Untitled Job',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(statusText),
                                  Text(
                                    'Applied on: ${DateTime.now().toString().split(' ')[0]}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                                  jobData['contractorEmail'] ??
                                                      'Unknown User',
                                              receiverID:
                                                  jobData['contractorId'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  const Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobDetailsPage(
                                      jobId: job.id,
                                      jobData: jobData,
                                      showApplyButton:
                                          !isSelected && !isRejected,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Invites Tab
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notifications')
                        .where('workerId', isEqualTo: currentUser.uid)
                        .where('type', isEqualTo: 'job_invite')
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
                          child: Text('No job invites yet'),
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
                          final createdAt =
                              notificationData['createdAt'] as Timestamp?;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('jobs')
                                .doc(jobId)
                                .get(),
                            builder: (context, jobSnapshot) {
                              if (!jobSnapshot.hasData) {
                                return const Card(
                                  child: ListTile(
                                    title: Text('Loading job details...'),
                                  ),
                                );
                              }

                              final jobData = jobSnapshot.data?.data()
                                      as Map<String, dynamic>? ??
                                  {};
                              final completeJobData = {
                                ...jobData,
                                'status': status,
                              };

                              IconData statusIcon;
                              Color statusColor;
                              String statusText;

                              if (status == 'accepted') {
                                statusIcon = Icons.check_circle;
                                statusColor = Colors.green;
                                statusText = 'Invite Accepted';
                              } else if (status == 'rejected') {
                                statusIcon = Icons.cancel;
                                statusColor = Colors.red;
                                statusText = 'Invite Declined';
                              } else {
                                statusIcon = Icons.mail;
                                statusColor = Colors.blue;
                                statusText = 'New Invite';
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: statusColor,
                                    child:
                                        Icon(statusIcon, color: Colors.white),
                                  ),
                                  title: Text(
                                    jobTitle ?? 'Untitled Job',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(statusText),
                                      if (createdAt != null)
                                        Text(
                                          'Received on: ${createdAt.toDate().toString().split(' ')[0]}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                                  receiverEmail: jobData[
                                                          'contractorEmail'] ??
                                                      'Unknown User',
                                                  receiverID:
                                                      jobData['contractorId'],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      const Icon(Icons.arrow_forward_ios),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JobInviteDetailsPage(
                                          jobId: jobId,
                                          notificationId: notification.id,
                                          jobData: completeJobData,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
