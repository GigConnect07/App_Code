import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example: Save worker profile
  Future<void> saveWorkerProfile(Map<String, dynamic> data) async {
    await _firestore.collection('workers').doc(data['uid']).set(data);
  }

  // Example: Fetch chat list
  Stream<QuerySnapshot> getChatList(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots();
  }
}