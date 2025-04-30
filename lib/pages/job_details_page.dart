import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final bool showApplyButton;

  const JobDetailsPage({
    super.key,
    required this.jobId,
    required this.jobData,
    this.showApplyButton = true,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _deleteJob() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job posting? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isLoading = true);

      try {
        // Delete the job document
        await _firestore.collection('jobs').doc(widget.jobId).delete();

        // Remove job from workers' applied jobs
        final jobDoc = await _firestore.collection('jobs').doc(widget.jobId).get();
        if (jobDoc.exists) {
          final applicants = jobDoc.data()?['applicants'] as List<dynamic>? ?? [];
          for (var applicantId in applicants) {
            await _firestore
                .collection('worker_profiles')
                .doc(applicantId)
                .collection('applied_jobs')
                .doc(widget.jobId)
                .delete();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting job: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          if (widget.jobData['employerId'] == _auth.currentUser?.uid)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteJob,
              tooltip: 'Delete Job',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            widget.jobData['title'] ?? 'Untitled Job',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Location', widget.jobData['location'] ?? 'Not specified'),
                          _buildInfoRow('Rate', '₹${widget.jobData['minRate'] ?? '0'} - ₹${widget.jobData['maxRate'] ?? '0'}'),
                          _buildInfoRow('Duration', widget.jobData['duration'] ?? 'Not specified'),
                          _buildInfoRow(
                            'Posted Date',
                            widget.jobData['timestamp'] != null
                                ? widget.jobData['timestamp'] is Timestamp
                                    ? (widget.jobData['timestamp'] as Timestamp).toDate().toString().split(' ')[0]
                                    : (widget.jobData['timestamp'] as DateTime).toString().split(' ')[0]
                                : 'Not specified',
                          ),
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
                          Text(widget.jobData['description'] ?? 'No description provided'),
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
                            children: (widget.jobData['skills'] as List<dynamic>? ?? [])
                                .map((skill) => Chip(
                                      label: Text(skill.toString()),
                                      backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.showApplyButton) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            final currentUser = _auth.currentUser;
                            if (currentUser == null) {
                              throw Exception('User not logged in');
                            }

                            // Add worker to applicants list
                            await _firestore.collection('jobs').doc(widget.jobId).update({
                              'applicants': FieldValue.arrayUnion([currentUser.uid]),
                            });

                            // Create notification for the contractor
                            await _firestore.collection('notifications').add({
                              'workerId': currentUser.uid,
                              'jobId': widget.jobId,
                              'jobTitle': widget.jobData['title'],
                              'contractorId': widget.jobData['employerId'],
                              'type': 'new_application',
                              'status': 'pending',
                              'createdAt': FieldValue.serverTimestamp(),
                              'read': false,
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Application submitted successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error applying for job: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Apply Now',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
