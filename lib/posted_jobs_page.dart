import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// PostedJobsPage: Shows all jobs posted by the current contractor.
class PostedJobsPage extends StatelessWidget {
  const PostedJobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Posted Jobs')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    final jobsStream = FirebaseFirestore.instance
        .collection('jobs')
        .where('contractorId', isEqualTo: currentUser.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('My Posted Jobs')),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('You have not posted any jobs yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final jobData = doc.data() as Map<String, dynamic>;

              final title = jobData['title'] ?? '';
              final description = jobData['description'] ?? '';
              final skills = (jobData['skills'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [];
              final paymentType = jobData['paymentType'] ?? '';
              final location = jobData['location'] ?? '';
              final duration = jobData['duration'] ?? '';
              final minRate = jobData['minRate'] ?? '';
              final maxRate = jobData['maxRate'] ?? '';
              DateTime? startDateTime;
              if (jobData['startDate'] != null && jobData['startDate'] is Timestamp) {
                startDateTime = (jobData['startDate'] as Timestamp).toDate();
              }
              final startDateStr = startDateTime != null ? DateFormat.yMMMd().format(startDateTime) : '';

              final applicantCount = jobData['applicants'] != null ? (jobData['applicants'] as List).length : 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobApplicationsPage(jobId: doc.id),
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
                                title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JobEditPage(jobId: doc.id, jobData: jobData),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Job'),
                                    content: const Text('Are you sure you want to delete this job?'),
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
                                if (confirm == true) {
                                  await FirebaseFirestore.instance.collection('jobs').doc(doc.id).delete();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(description),
                        const SizedBox(height: 8),
                        if (skills.isNotEmpty) Text('Skills: ${skills.join(', ')}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Payment: $paymentType'),
                            const SizedBox(width: 16),
                            Text('Location: $location'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (startDateStr.isNotEmpty) Text('Start: $startDateStr'),
                            if (startDateStr.isNotEmpty) const SizedBox(width: 16),
                            Text('Duration: $duration'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Rate: \$$minRate - \$$maxRate'),
                        const SizedBox(height: 8),
                        Text('Applicants: $applicantCount'),
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

class JobApplicationsPage extends StatelessWidget {
  final String jobId;
  const JobApplicationsPage({Key? key, required this.jobId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Applications')),
      body: Center(child: Text('Show applicants for job: $jobId')),
    );
  }
}

class JobEditPage extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const JobEditPage({Key? key, required this.jobId, required this.jobData}) : super(key: key);

  @override
  State<JobEditPage> createState() => _JobEditPageState();
}

class _JobEditPageState extends State<JobEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.jobData['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.jobData['description'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({
      'title': _titleController.text,
      'description': _descriptionController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Job Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Job Description'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
