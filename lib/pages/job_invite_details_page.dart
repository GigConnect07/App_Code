import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/pages/chat_page.dart';

class JobInviteDetailsPage extends StatelessWidget {
  final String jobId;
  final String notificationId;
  final Map<String, dynamic> jobData;

  const JobInviteDetailsPage({
    super.key,
    required this.jobId,
    required this.notificationId,
    required this.jobData,
  });

  Future<void> _handleInviteResponse(
      BuildContext context, String status) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Update notification status
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'status': status,
        'read': true,
      });

      // If accepted, add worker to selected applicants
      if (status == 'accepted') {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
          'selectedApplicants': FieldValue.arrayUnion([currentUser.uid]),
        });
      }

      // Create notification for contractor
      await FirebaseFirestore.instance.collection('notifications').add({
        'contractorId': jobData['contractorId'],
        'workerId': currentUser.uid,
        'jobId': jobId,
        'jobTitle': jobData['title'],
        'type': 'invite_response',
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Job invite ${status == 'accepted' ? 'accepted' : 'declined'} successfully!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Invite Details'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobData['title'] ?? 'Untitled Job',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        'Location', jobData['location'] ?? 'Not specified'),
                    _buildInfoRow('Budget', '₹${jobData['budget'] ?? '0'}'),
                    _buildInfoRow(
                        'Duration', jobData['duration'] ?? 'Not specified'),
                    _buildInfoRow(
                        'Posted Date',
                        jobData['postedDate']?.toString().split(' ')[0] ??
                            'Not specified'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(jobData['description'] ?? 'No description provided'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Skills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          (jobData['requiredSkills'] as List<dynamic>? ?? [])
                              .map((skill) => Chip(
                                    label: Text(skill.toString()),
                                    backgroundColor: Colors.deepPurpleAccent
                                        .withOpacity(0.2),
                                  ))
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (jobData['status'] == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleInviteResponse(context, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Decline'),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleInviteResponse(context, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            if (jobData['status'] == 'accepted')
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverEmail:
                              jobData['contractorEmail'] ?? 'Unknown User',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
