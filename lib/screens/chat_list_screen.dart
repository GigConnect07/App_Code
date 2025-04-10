
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: currentUser == null
          ? const Center(child: Text('Please log in to view chats'))
          : StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data?.docs ?? [];

          if (chats.isEmpty) {
            return const Center(child: Text('No chats available'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final participants = List<String>.from(chat['participants']);
              final otherUserId = participants.firstWhere(
                    (id) => id != currentUser.uid,
                orElse: () => '',
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return const ListTile(title: Text('Unknown user'));
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userData?['profileImage'] ?? ''),
                    ),
                    title: Text(userData?['name'] ?? 'Unknown'),
                    subtitle: Text(chat['lastMessage'] ?? ''),
                    onTap: () {
                      // Navigate to chat screen
                    },
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