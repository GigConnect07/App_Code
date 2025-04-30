import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_posting.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobPostingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'jobs';

  // Get all job postings
  Stream<List<JobPosting>> getJobPostings() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Received ${snapshot.docs.length} job documents from Firestore');

      if (snapshot.docs.isEmpty) {
        print('No jobs found in the database');
        return [];
      }

      try {
        final jobPostings = snapshot.docs.map((doc) {
          print('Processing job document: ${doc.id}');
          print('Document data: ${doc.data()}');
          return JobPosting.fromMap(doc.data(), doc.id);
        }).toList();

        // Filter out jobs where the current user has already applied, been approved, or rejected
        final filteredJobPostings = jobPostings.where((job) {
          final jobData =
              snapshot.docs.firstWhere((doc) => doc.id == job.id).data();
          final applicants = jobData['applicants'] as List<dynamic>? ?? [];
          final selectedApplicant = jobData['selectedApplicant'] as String?;
          final rejectedApplicants =
              jobData['rejectedApplicants'] as List<dynamic>? ?? [];

          // Return false if the current user has applied, been approved, or rejected
          return !applicants.contains(currentUserId) &&
              selectedApplicant != currentUserId &&
              !rejectedApplicants.contains(currentUserId);
        }).toList();

        print('Successfully converted ${filteredJobPostings.length} jobs');
        return filteredJobPostings;
      } catch (e, stackTrace) {
        print('Error converting job documents: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    });
  }
}
