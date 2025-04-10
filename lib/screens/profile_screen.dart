import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import '../widgets/skill_assessment_card.dart';

class ProfileScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProfileScreen({
    super.key,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  User? _user;
  Map<String, dynamic>? userData;
  File? _backgroundImage;
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.auth.currentUser;
    _loadUserData();
    _logProfileView();
  }

  Future<void> _logProfileView() async {
    await _analytics.logEvent(
      name: 'profile_view',
      parameters: {'user_id': _user?.uid ?? 'unknown_user'},
    );
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;

    setState(() => _isLoading = true);
    try {
      final doc = await widget.firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        setState(() => userData = doc.data() ?? <String, dynamic>{});
      }
    } catch (e) {
      _showError('Failed to load profile data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage(bool isProfile) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image == null) return;

      final mime = lookupMimeType(image.path);
      if (mime == null || !['image/jpeg', 'image/png'].contains(mime)) {
        _showError('Only JPG/PNG images allowed');
        return;
      }

      final file = File(image.path);
      final size = await file.length();
      if (size > 5 * 1024 * 1024) {
        _showError('Image must be smaller than 5MB');
        return;
      }

      setState(() => isProfile ? _profileImage = file : _backgroundImage = file);

      final ref = _storage.ref().child(
        'users/${_user!.uid}/${isProfile ? 'profile' : 'background'}.jpg',
      );
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await widget.firestore.collection('users').doc(_user!.uid).update({
        isProfile ? 'profileImage' : 'backgroundImage': url,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _loadUserData();
    } catch (e) {
      _showError('Failed to upload image');
    }
  }

  Future<void> _shareProfile() async {
    try {
      await Share.share(
        'Check out my profile on Gig Connect!',
        subject: 'Gig Connect Profile',
      );
    } catch (e) {
      _showError('Failed to share profile');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userData?['name'] ?? 'No Name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (userData?['profileType'] == 'recruiter')
            Text(
              'Recruiter at ${userData?['company'] ?? ''}',
              style: Theme.of(context).textTheme.bodyLarge,
            )
          else
            Text(
              userData?['skills']?.join(' • ') ?? 'Skilled Worker',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final ImageProvider? image = _profileImage != null
        ? FileImage(_profileImage!)
        : (userData?['profileImage'] != null
        ? NetworkImage(userData!['profileImage'].toString())
        : null);

    return GestureDetector(
      onTap: () => _uploadImage(true),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        backgroundImage: image,
        child: image == null
            ? const Icon(Icons.person, size: 50, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final ImageProvider? image = _backgroundImage != null
        ? FileImage(_backgroundImage!)
        : (userData?['backgroundImage'] != null
        ? NetworkImage(userData!['backgroundImage'].toString())
        : null);

    return GestureDetector(
      onTap: () => _uploadImage(false),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          image: image != null
              ? DecorationImage(
            image: image,
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: image == null
            ? const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey))
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view profile')),
      );
    }

    if (_isLoading || userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: _buildBackgroundImage(),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareProfile,
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildProfileHeader(),
              _buildProfileImage(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkillAssessmentCard(skill: 'Flutter'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}