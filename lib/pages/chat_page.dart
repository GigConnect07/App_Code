import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/components/chat_bubble.dart';
import 'package:gig_connect/components/mytextfield_chat.dart';
import 'package:gig_connect/services/auth_service.dart';
import 'package:gig_connect/services/chat_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key, required this.receiverEmail, required this.receiverID});
  final String receiverEmail;
  final String receiverID;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final TextEditingController _messagecontroller = TextEditingController();

  //chat and auth services
  final ChatServices _chatServices = ChatServices();

  final AuthService _authServices = AuthService();
  //for textfield focus
  final FocusNode myFocusNode = FocusNode();

  //scroll controller
  final ScrollController _scrollController = ScrollController();

  String receiverName = "Unknown User";

  @override
  void initState() {
    super.initState();

    // Fetch receiver's name from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverID)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          receiverName = doc['name'] ?? widget.receiverEmail;
        });
      } else {
        setState(() {
          receiverName = widget.receiverEmail;
        });
      }
    });

    //add listener to Focusnode
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        //cause a delay so that keyboard has time to show up
        //then the amount of remaining space will be calculated,
        //then scroll down
        Future.delayed(const Duration(milliseconds: 500), () {
          scrollDown();
        });
      }
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messagecontroller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //send message
  void _sendMessage() async {
    //if there is  something inside the textfield
    if (_messagecontroller.text.isNotEmpty) {
      //send the message
      await _chatServices.sendMessage(
          widget.receiverID, _messagecontroller.text);

      //clear text controller
      _messagecontroller.clear();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(child: _buildMessageList()),
          //user input
          _buildUserInput()
        ],
      ),
    );
  }

  //buid message list
  Widget _buildMessageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: _chatServices.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Scroll to bottom only when new messages are added
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollDown();
          });
        }

        //return listview
        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser =
        data["senderId"] == FirebaseAuth.instance.currentUser!.uid;
    print("Message senderId: ${data["senderId"]}, Current user: ${FirebaseAuth.instance.currentUser!.uid}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: null,
              backgroundColor: Colors.purple,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ChatBubble(
              isCurrentUser: isCurrentUser,
              message: data["message"],
              timestamp: (data["timestamp"] as Timestamp).toDate(),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: null,
              backgroundColor: Colors.purple,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ],
      ),
    );
  }

  //build message Input
  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Mychattextfield(
              hintText: "Type your message",
              obscureText: false,
              controller: _messagecontroller,
              focusNode: myFocusNode,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF6A1B9A),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class Mytextfield {}
