import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final String role;
  final String personalInfo;
  final String skills;
  final String workHistory;
  final VoidCallback onEditPressed;

  const ProfilePage({
    super.key,
    required this.username,
    required this.role,
    required this.personalInfo,
    required this.skills,
    required this.workHistory,
    required this.onEditPressed,
  });

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
                fontSize: 20),
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage("https://i.imgur.com/OB0y6MR.jpg"),
            ),
            const SizedBox(height: 15),
            Text(
              username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              role,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 20),
            _buildInfoCard("Personal Information", personalInfo),
            _buildInfoCard("Skills", skills),
            _buildInfoCard("Work History", workHistory),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onEditPressed,
              child: const Text("Edit Profile"),
            ),
          ],
        )
      ],
    );
  }
}
