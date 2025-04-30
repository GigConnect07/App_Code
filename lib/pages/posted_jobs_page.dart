import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:gig_connect/pages/view_profile_page.dart';
import 'package:gig_connect/pages/worker_search_page.dart';
import 'package:gig_connect/pages/chat_page.dart';

/// PostedJobsPage: Shows all jobs posted by the current contractor.
class PostedJobsPage extends StatelessWidget {
  const PostedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posted Jobs')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    final jobsStream = FirebaseFirestore.instance
        .collection('jobs')
        .where('contractorId', isEqualTo: currentUser.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posted Jobs'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  return const Center(
                      child: Text('You have not posted any jobs yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final jobData = doc.data() as Map<String, dynamic>;

                    final title = jobData['title'] ?? '';
                    final description = jobData['description'] ?? '';
                    final skills = (jobData['skills'] as List<dynamic>?)
                            ?.map((s) => s.toString())
                            .toList() ??
                        [];
                    final paymentType = jobData['paymentType'] ?? '';
                    final location = jobData['location'] ?? '';
                    final duration = jobData['duration'] ?? '';
                    final minRate = jobData['minRate'] ?? '';
                    final maxRate = jobData['maxRate'] ?? '';
                    DateTime? startDateTime;
                    if (jobData['startDate'] != null &&
                        jobData['startDate'] is Timestamp) {
                      startDateTime =
                          (jobData['startDate'] as Timestamp).toDate();
                    }
                    final startDateStr = startDateTime != null
                        ? DateFormat.yMMMd().format(startDateTime)
                        : '';

                    final applicantCount = jobData['applicants'] != null
                        ? (jobData['applicants'] as List).length
                        : 0;

                    final selectedApplicants =
                        (jobData['selectedApplicants'] as List<dynamic>?) ?? [];
                    final selectedApplicantCount = selectedApplicants.length;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailsPage(
                                jobId: doc.id,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JobEditPage(
                                              jobId: doc.id, jobData: jobData),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Job'),
                                          content: const Text(
                                              'Are you sure you want to delete this job?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance
                                            .collection('jobs')
                                            .doc(doc.id)
                                            .delete();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(description),
                              const SizedBox(height: 8),
                              if (skills.isNotEmpty)
                                Text('Skills: ${skills.join(', ')}'),
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
                                  if (startDateStr.isNotEmpty)
                                    Text('Start: $startDateStr'),
                                  if (startDateStr.isNotEmpty)
                                    const SizedBox(width: 16),
                                  Text('Duration: $duration'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Rate: ₹$minRate - ₹$maxRate'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    applicantCount > 0
                                        ? Icons.people
                                        : Icons.people_outline,
                                    color: applicantCount > 0
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$applicantCount ${applicantCount == 1 ? 'applicant' : 'applicants'}',
                                    style: TextStyle(
                                      color: applicantCount > 0
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (selectedApplicantCount > 0) ...[
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$selectedApplicantCount ${selectedApplicantCount == 1 ? 'worker selected' : 'workers selected'}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: TextField(
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkerSearchPage(),
                  ),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search workers by skills...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JobDetailsPage extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const JobDetailsPage({
    super.key,
    required this.jobId,
    required this.jobData,
  });

  @override
  Widget build(BuildContext context) {
    final selectedApplicants =
        (jobData['selectedApplicants'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InviteWorkersPage(jobId: jobId),
                ),
              );
            },
            tooltip: 'Invite Workers',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title
            Text(
              jobData['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Job Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              jobData['description'] ?? 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Selected Workers Section
            if (selectedApplicants.isNotEmpty) ...[
              const Text(
                'Selected Workers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...selectedApplicants
                  .map((workerId) => StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('worker_profiles')
                            .doc(workerId)
                            .snapshots(),
                        builder: (context, workerSnapshot) {
                          if (!workerSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final workerData = workerSnapshot.data?.data()
                              as Map<String, dynamic>?;
                          if (workerData == null) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                            workerData['username'] ?? 'Worker',
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
                                              receiverID: workerId,
                                            ),
                                          ),
                                        );
                                      },
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
                                    children:
                                        (workerData['skills'] as List<dynamic>)
                                            .map((skill) => Chip(
                                                  label: Text(skill.toString()),
                                                  backgroundColor: Colors
                                                      .deepPurpleAccent
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
                                  Text(
                                    workerData['experience'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ))
                  ,
            ],

            const SizedBox(height: 16),

            // Skills
            if (jobData['skills'] != null && jobData['skills'] is List)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (jobData['skills'] as List<dynamic>)
                        .map((skill) => Chip(
                              label: Text(skill.toString()),
                              backgroundColor:
                                  Colors.deepPurpleAccent.withOpacity(0.2),
                            ))
                        .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Job Details
            const Text(
              'Job Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Location', jobData['location'] ?? 'Not specified'),
            _buildDetailRow(
                'Payment Type', jobData['paymentType'] ?? 'Not specified'),
            _buildDetailRow('Duration', jobData['duration'] ?? 'Not specified'),
            _buildDetailRow('Rate',
                '₹${jobData['minRate'] ?? '0'} - ₹${jobData['maxRate'] ?? '0'}'),

            if (jobData['startDate'] != null)
              _buildDetailRow(
                'Start Date',
                jobData['startDate'] is Timestamp
                    ? (jobData['startDate'] as Timestamp)
                        .toDate()
                        .toString()
                        .split(' ')[0]
                    : (jobData['startDate'] as DateTime)
                        .toString()
                        .split(' ')[0],
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class JobApplicationsPage extends StatelessWidget {
  final String jobId;
  const JobApplicationsPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Applications'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .doc(jobId)
            .snapshots(),
        builder: (context, jobSnapshot) {
          if (jobSnapshot.hasError) {
            return Center(child: Text('Error: ${jobSnapshot.error}'));
          }

          if (jobSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobData = jobSnapshot.data?.data() as Map<String, dynamic>?;
          if (jobData == null) {
            return const Center(child: Text('Job not found'));
          }

          final applicants = jobData['applicants'] as List<dynamic>? ?? [];
          final selectedApplicants =
              jobData['selectedApplicants'] as List<dynamic>? ?? [];

          if (applicants.isEmpty) {
            return const Center(
              child: Text('No applications yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final applicantId = applicants[index];
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('worker_profiles')
                    .doc(applicantId)
                    .snapshots(),
                builder: (context, applicantSnapshot) {
                  if (applicantSnapshot.hasError) {
                    return const SizedBox.shrink();
                  }

                  if (applicantSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: LinearProgressIndicator(),
                    );
                  }

                  final applicantData =
                      applicantSnapshot.data?.data() as Map<String, dynamic>?;
                  if (applicantData == null) {
                    return const SizedBox.shrink();
                  }

                  final isSelected = selectedApplicants.contains(applicantId);

                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: null,
                            backgroundColor: Colors.purple,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            applicantData['username'] ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              applicantData['role'] ?? 'No role specified'),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProfilePage(
                                  userId: applicantId,
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Skills:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(applicantData['skills'] ??
                                  'No skills specified'),
                              const SizedBox(height: 8),
                              const Text(
                                'Experience:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(applicantData['experience'] ??
                                  'No experience specified'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isSelected)
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('jobs')
                                        .doc(jobId)
                                        .update({
                                      'selectedApplicants':
                                          FieldValue.arrayUnion([applicantId]),
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text('Select Worker'),
                                ),
                              if (isSelected)
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('jobs')
                                        .doc(jobId)
                                        .update({
                                      'selectedApplicants':
                                          FieldValue.arrayRemove([applicantId]),
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text('Remove Worker'),
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
          );
        },
      ),
    );
  }
}

class JobEditPage extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const JobEditPage({super.key, required this.jobId, required this.jobData});

  @override
  State<JobEditPage> createState() => _JobEditPageState();
}

class _JobEditPageState extends State<JobEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.jobData['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.jobData['description'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .update({
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

class InviteWorkersPage extends StatefulWidget {
  final String jobId;

  const InviteWorkersPage({super.key, required this.jobId});

  @override
  State<InviteWorkersPage> createState() => _InviteWorkersPageState();
}

class _InviteWorkersPageState extends State<InviteWorkersPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _searchQuery = '';
  String _locationFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showLocationFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Location'),
        content: TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: 'Enter location...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _locationFilter = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _locationController.clear();
              setState(() {
                _locationFilter = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _inviteWorker(String workerId) async {
    try {
      // Get job details for the notification
      final jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .get();
      final jobData = jobDoc.data() as Map<String, dynamic>;

      // Add worker to invited workers list
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({
        'invitedWorkers': FieldValue.arrayUnion([workerId]),
      });

      // Create notification for the worker
      await FirebaseFirestore.instance.collection('notifications').add({
        'workerId': workerId,
        'jobId': widget.jobId,
        'jobTitle': jobData['title'],
        'contractorId': jobData['contractorId'],
        'type': 'job_invite',
        'status': 'pending', // pending, accepted, declined
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worker invited successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inviting worker: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Workers'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showLocationFilterDialog,
            tooltip: 'Filter by location',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by skills or role...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                if (_locationFilter.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Chip(
                          label: Text('Location: $_locationFilter'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            _locationController.clear();
                            setState(() {
                              _locationFilter = '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('worker_profiles')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final workers = snapshot.data?.docs ?? [];

                // Filter workers based on case-insensitive search and location
                final filteredWorkers = workers.where((doc) {
                  final worker = doc.data() as Map<String, dynamic>;
                  final skills =
                      worker['skills']?.toString().toLowerCase() ?? '';
                  final role = worker['role']?.toString().toLowerCase() ?? '';
                  final location =
                      worker['location']?.toString().toLowerCase() ?? '';
                  final searchLower = _searchQuery.toLowerCase();
                  final locationLower = _locationFilter.toLowerCase();

                  bool matchesSearch = _searchQuery.isEmpty ||
                      skills.contains(searchLower) ||
                      role.contains(searchLower);

                  bool matchesLocation = _locationFilter.isEmpty ||
                      location.contains(locationLower);

                  return matchesSearch && matchesLocation;
                }).toList();

                if (filteredWorkers.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty && _locationFilter.isEmpty
                          ? 'No workers found'
                          : 'No workers found matching your criteria',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker =
                        filteredWorkers[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: null,
                          backgroundColor: Colors.purple,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          worker['username'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker['role'] ?? 'No role specified'),
                            if (worker['skills'] != null)
                              Text(
                                'Skills: ${worker['skills']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (worker['location'] != null)
                              Text(
                                'Location: ${worker['location']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewProfilePage(
                                      userId: filteredWorkers[index].id,
                                    ),
                                  ),
                                );
                              },
                              tooltip: 'View Profile',
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _inviteWorker(filteredWorkers[index].id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Invite'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
