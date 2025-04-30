import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gig_connect/pages/chat_page.dart';

class ViewProfilePage extends StatelessWidget {
  final String userId;

  const ViewProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('worker_profiles')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: null,
                    backgroundColor: Colors.purple,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            data['username'] ?? 'No name',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data['role'] ?? 'No role specified',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.chat,
                            color: Colors.deepPurpleAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverEmail: data['email'] ?? 'Unknown User',
                                receiverID: userId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard("Personal Information",
                      data['personalInfo'] ?? 'No personal info provided'),
                  _buildInfoCard("Skills", data['skills'] ?? 'No skills added'),
                  _buildInfoCard("Work History",
                      data['workHistory'] ?? 'No work history provided'),
                  _buildInfoCard("Experience",
                      data['experience'] ?? 'No experience specified'),
                  _buildInfoCard(
                      "Location", data['location'] ?? 'No location specified'),
                  _buildInfoCard("Availability",
                      data['availability'] ?? 'No availability specified'),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
