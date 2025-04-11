// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RecruiterScreen())),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(userData: userData),
                const SizedBox(height: 24),
                _AboutSection(userData: userData),
                const SizedBox(height: 24),
                if (userData['userType'] == 'recruiter') ...[
                  _IndustryPreferences(userData: userData),
                  const SizedBox(height: 24),
                ],
                _SkillsSection(userData: userData),
                const SizedBox(height: 24),
                _AIGenerateButton(userId: user.uid),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;

  const _ProfileHeader({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(userData['coverImage'] ?? ''),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(userData['profileImage'] ?? ''),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _updateProfileImage(context),
          ),
        ),
      ],
    );
  }

  Future<void> _updateProfileImage(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload to Firebase Storage and update Firestore
    }
  }
}

class _AboutSection extends StatefulWidget {
  final Map<String, dynamic> userData;

  const _AboutSection({required this.userData});

  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(text: widget.userData['about']);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context),
                ),
              ],
            ),
            Text(widget.userData['about'] ?? ''),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit About'),
        content: TextField(
          controller: _aboutController,
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({'about': _aboutController.text});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _IndustryPreferences extends StatelessWidget {
  final Map<String, dynamic> userData;

  const _IndustryPreferences({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Industries I Hire For',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...(userData['industries'] ?? []).map<Widget>((industry) => ListTile(
              title: Text(industry['name']),
              subtitle: Text(industry['description']),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {/* Edit industry */},
              ),
            )).toList(),
            TextButton(
              onPressed: () {/* Add new industry */},
              child: const Text('Add Industry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final Map<String, dynamic> userData;

  const _SkillsSection({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Skills',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (userData['skills'] ?? []).map<Widget>((skill) => Chip(
                label: Text(skill),
                backgroundColor: Colors.purple.withOpacity(0.1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIGenerateButton extends StatefulWidget {
  final String userId;

  const _AIGenerateButton({required this.userId});

  @override
  State<_AIGenerateButton> createState() => _AIGenerateButtonState();
}

class _AIGenerateButtonState extends State<_AIGenerateButton> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: _isGenerating
          ? const CircularProgressIndicator()
          : const Icon(Icons.auto_awesome),
      label: const Text('Generate Skills with AI'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBA55D3),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _isGenerating ? null : _generateSkills,
    );
  }

  Future<void> _generateSkills() async {
    setState(() => _isGenerating = true);

    try {
      // Call Deepseek API
      // final response = await http.post(...);

      // Process response and update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'skills': FieldValue.arrayUnion(newSkills)});
    } finally {
      setState(() => _isGenerating = false);
    }
  }
}