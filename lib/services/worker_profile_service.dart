import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/worker_profile.dart';

class WorkerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's worker profile
  Future<WorkerProfile?> getWorkerProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc =
          await _firestore.collection('worker_profiles').doc(user.uid).get();
      if (doc.exists) {
        return WorkerProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting worker profile: $e');
      return null;
    }
  }

  // Create or update worker profile
  Future<void> saveWorkerProfile(WorkerProfile profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('worker_profiles')
          .doc(user.uid)
          .set(profile.toMap());
    } catch (e) {
      print('Error saving worker profile: $e');
      rethrow;
    }
  }

  // Stream worker profile changes
  Stream<WorkerProfile?> streamWorkerProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('worker_profiles')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? WorkerProfile.fromMap(doc.data()!) : null);
  }
}
