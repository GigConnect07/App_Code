import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({Key? key}) : super(key: key);

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final locationController = TextEditingController();
  final minRateController = TextEditingController();
  final maxRateController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final skillsController = TextEditingController();

  String? jobType;
  String? experienceLevel;
  String? duration;
  String paymentType = 'hourly';
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get reference to contractor document
        final contractorRef =
            FirebaseFirestore.instance.collection('Contractor').doc(user.uid);

        // Create job in subcollection
        await contractorRef.collection('Job Applications Post').add({
          'title': titleController.text.trim(),
          'company': companyController.text.trim(),
          'location': locationController.text.trim(),
          'minRate': minRateController.text.trim(),
          'maxRate': maxRateController.text.trim(),
          'description': descriptionController.text.trim(),
          'requirements': requirementsController.text.trim(),
          'skills': skillsController.text.trim(),
          'jobType': jobType,
          'experienceLevel': experienceLevel,
          'duration': duration,
          'paymentType': paymentType,
          'startDate': selectedDate,
          'timestamp': FieldValue.serverTimestamp(),
          'applicants': [],
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')),
        );

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          selectedDate = null;
          jobType = null;
          experienceLevel = null;
          duration = null;
          paymentType = 'hourly';
        });
      }
    }
  }

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
          // Handle loading/error states first
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No jobs posted yet"));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final jobData = job.data() as Map<String, dynamic>;

              // Add null checks for all fields
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(jobData['title'] ?? 'Untitled Job'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jobData['location'] ?? 'Location not specified'),
                      const SizedBox(height: 4),
                      Text(
                        'Rate: ${jobData['minRate'] ?? ''} - ${jobData['maxRate'] ?? ''}',
                      ),
                      if (jobData['startDate'] != null)
                        Text(
                          'Start: ${(jobData['startDate'] as Timestamp).toDate().toString().split(' ')[0]}',
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
