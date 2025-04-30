import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/pages/chat_page.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    // Try worker_profiles
    var doc = await FirebaseFirestore.instance
        .collection('worker_profiles')
        .doc(userId)
        .get();
    if (doc.exists) return doc.data();
    // Try users
    doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) return doc.data();
    // Try contractor_profiles
    doc = await FirebaseFirestore.instance
        .collection('contractor_profiles')
        .doc(userId)
        .get();
    if (doc.exists) return doc.data();
    return null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.inversePrimary),
        title: Text('Chats',
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .where('participants', arrayContains: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chatRooms = snapshot.data?.docs ?? [];
                if (chatRooms.isEmpty) {
                  return const Center(child: Text('No chats yet'));
                }
                return ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    final chatRoomData =
                        chatRoom.data() as Map<String, dynamic>;
                    final participants =
                        chatRoomData['participants'] as List<dynamic>;
                    final otherUserId = participants.firstWhere(
                      (id) => id != currentUser.uid,
                      orElse: () => '',
                    );
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getUserData(otherUserId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(title: Text('Loading...'));
                        }
                        final userData = userSnapshot.data ?? {};
                        final username = userData['username'] ??
                            userData['name'] ??
                            'Unknown User';
                        final email = userData['email'] ?? '';
                        if (_searchQuery.isNotEmpty &&
                            !username
                                .toString()
                                .toLowerCase()
                                .contains(_searchQuery) &&
                            !email
                                .toString()
                                .toLowerCase()
                                .contains(_searchQuery)) {
                          return const SizedBox.shrink();
                        }
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: null,
                            backgroundColor: Colors.purple,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(username),
                          subtitle: Text(email),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  receiverEmail:
                                      email.isNotEmpty ? email : 'Unknown User',
                                  receiverID: otherUserId,
                                ),
                              ),
                            );
                          },
                        );
                      },
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
