import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_posting.dart';

class JobPostingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'jobs';

  // Get all job postings
  Stream<List<JobPosting>> getJobPostings() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobPosting.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
