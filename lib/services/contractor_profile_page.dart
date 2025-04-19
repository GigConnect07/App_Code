import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'contractor_main_screen.dart';

class ContractorProfilePage extends StatefulWidget {
  const ContractorProfilePage({super.key});

  @override
  State<ContractorProfilePage> createState() => _ContractorProfilePageState();
}

class _ContractorProfilePageState extends State<ContractorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  bool _isEditing = false;
  Map<String, List<String>> _skills = {};

  User? _user;
  DocumentReference? _userRef;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _userRef = _firestore.collection('users').doc(_user!.uid);
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (_userRef != null) {
      final snapshot = await _userRef!.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _cityController.text = data['city'] ?? '';
          _pinCodeController.text = data['pinCode'] ?? '';
          _skills = Map<String, List<String>>.from(
            (data['skills'] ?? {}).map((key, value) => MapEntry(key, List<String>.from(value))),
          );
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      // Update user data
      await _userRef?.update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'pinCode': _pinCodeController.text,
        'profileCompleted': true, // Set profile as completed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // Navigate to the main screen after profile update
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ContractorMainScreen()),
      );
    }
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon, {bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildSkillsSection() {
    if (_skills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        ..._skills.entries.map((entry) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: entry.value.map((skill) {
                return Chip(label: Text(skill));
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Profile'),
        backgroundColor: const Color(0xFFBA55D3),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/avatar.png')),
              const SizedBox(height: 30),
              _buildProfileField("Full Name", _nameController, Icons.person, enabled: _isEditing),
              _buildProfileField("Email", _emailController, Icons.email), // Not editable
              _buildProfileField("Phone Number", _phoneController, Icons.phone, enabled: _isEditing),
              _buildProfileField("City", _cityController, Icons.location_city, enabled: _isEditing),
              _buildProfileField("Pin Code", _pinCodeController, Icons.pin_drop, enabled: _isEditing),
              _buildSkillsSection(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isEditing = !_isEditing);
                      if (!_isEditing) _loadUserData(); // Revert if cancelled
                    },
                    icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
                    label: Text(_isEditing ? 'Cancel' : 'Edit'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  if (_isEditing)
                    ElevatedButton.icon(
                      onPressed: _updateUserData,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(receiverId: 'workerUid123'), // Replace dynamically
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat with Worker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
