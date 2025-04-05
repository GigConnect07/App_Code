import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String username;

  const UserProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: const Center(
        child: Text(
          "This is the user's profile page.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
