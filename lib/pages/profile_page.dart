import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
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

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profilePicUrl;
  bool _loadingPic = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
  }

  Future<void> _loadProfilePic() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('worker_profiles')
        .doc(uid)
        .get();
    setState(() {
      _profilePicUrl = doc.data()?['profilePictureUrl'];
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _loadingPic = true;
      });

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Create a reference to the profile pictures folder
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('$uid.jpg');

      // Upload the file
      final uploadTask = await storageRef.putFile(File(pickedFile.path));

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('worker_profiles')
          .doc(uid)
          .update({'profilePictureUrl': downloadUrl});

      setState(() {
        _profilePicUrl = downloadUrl;
        _loadingPic = false;
      });
    } catch (e) {
      setState(() {
        _loadingPic = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    }
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
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profilePicUrl != null
                      ? NetworkImage(_profilePicUrl!)
                      : null,
                  backgroundColor: Colors.purple,
                  child: _profilePicUrl == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        )
                      : null,
                ),
                if (_loadingPic)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              widget.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.role,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 20),
            _buildInfoCard("Personal Information", widget.personalInfo),
            _buildInfoCard("Skills", widget.skills),
            _buildInfoCard("Work History", widget.workHistory),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onEditPressed,
              child: const Text("Edit Profile"),
            ),
          ],
        )
      ],
    );
  }
}
