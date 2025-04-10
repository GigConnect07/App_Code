import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

Future<void> seedChats() async {
  await firestore.collection('chats').doc('chat1').set({
    'participants': ['user1', 'user2'],
    'lastMessage': 'Hello!',
    'lastMessageTime': FieldValue.serverTimestamp(),
  });

  await firestore.collection('chats/chat1/messages').add({
    'text': 'Hello!',
    'sender': 'user1',
    'timestamp': FieldValue.serverTimestamp(),
  });
}