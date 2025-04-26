import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isEditing = false;
  List<String> _skills = [];
  File? _profileImage;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() => _profileImage = File(pickedImage.path));
      // TODO: Upload to Firebase Storage and update imageURL if needed
    }
  }

  Future<void> _loadUserData() async {
    if (_userRef != null) {
      final snapshot = await _userRef!.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _companyNameController.text = data['companyName'] ?? '';
          _cityController.text = data['city'] ?? '';
          _addressController.text = data['address'] ?? '';
          _stateController.text = data['state'] ?? '';
          _zipCodeController.text = data['zipCode'] ?? '';
          _experienceController.text = (data['yearsOfExperience'] ?? '').toString();
          _specializationController.text = data['specialization'] ?? '';
          _bioController.text = data['bio'] ?? '';
          if (data['skills'] != null) {
            _skills = List<String>.from(data['skills']);
          } else {
            _skills = [];
          }
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _userRef?.update({
          'fullName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'companyName': _companyNameController.text.trim(),
          'city': _cityController.text.trim(),
          'address': _addressController.text.trim(),
          'state': _stateController.text.trim(),
          'zipCode': _zipCodeController.text.trim(),
          'yearsOfExperience': _experienceController.text.trim(),
          'specialization': _specializationController.text.trim(),
          'bio': _bioController.text.trim(),
          'skills': _skills,
          'profileCompleted': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        setState(() => _isEditing = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon,
      {bool enabled = false}) {
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
        validator: (value) =>
        (enabled && (value == null || value.isEmpty)) ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        if (_skills.isNotEmpty)
          Wrap(
            spacing: 8,
            children: _skills.map((skill) {
              return Chip(
                label: Text(skill),
                onDeleted: _isEditing
                    ? () => setState(() => _skills.remove(skill))
                    : null,
              );
            }).toList(),
          )
        else
          const Text("No skills added"),
        if (_isEditing)
          TextFormField(
            decoration: const InputDecoration(labelText: "Add Skill"),
            onFieldSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() => _skills.add(value));
              }
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (!_isEditing) _loadUserData(); // Reload data if cancelling edit
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/avatar.png') as ImageProvider,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickImage,
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileField("Full Name", _nameController, Icons.person, enabled: _isEditing),
              _buildProfileField("Email", _emailController, Icons.email, enabled: false),
              _buildProfileField("Phone Number", _phoneController, Icons.phone, enabled: _isEditing),
              _buildProfileField("Company Name", _companyNameController, Icons.business, enabled: _isEditing),
              _buildProfileField("Street Address", _addressController, Icons.location_on, enabled: _isEditing),
              _buildProfileField("City", _cityController, Icons.location_city, enabled: _isEditing),
              _buildProfileField("State", _stateController, Icons.map, enabled: _isEditing),
              _buildProfileField("Zip Code", _zipCodeController, Icons.pin_drop, enabled: _isEditing),
              _buildProfileField("Years of Experience", _experienceController, Icons.timeline, enabled: _isEditing),
              _buildProfileField("Specialization", _specializationController, Icons.build, enabled: _isEditing),
              _buildProfileField("Bio", _bioController, Icons.info, enabled: _isEditing),
              _buildSkillsSection(),
              const SizedBox(height: 20),
              if (_isEditing)
                ElevatedButton.icon(
                  onPressed: _updateUserData,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
