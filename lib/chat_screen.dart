import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId; // worker ID

  const ChatScreen({Key? key, required this.receiverId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    FirebaseFirestore.instance.collection('chats').add({
      'text': _controller.text.trim(),
      'senderId': currentUserId,
      'receiverId': widget.receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('senderId', whereIn: [currentUserId, widget.receiverId])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = chatSnapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) {
                    final data = docs[index];
                    bool isMe = data['senderId'] == currentUserId;
                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(data['text']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
