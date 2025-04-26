import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'contractor_main_screen.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _profileImage;
  List<String> _selectedSkills = [];

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // Submit form and save data to Firestore
  void _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in.")),
        );
        return;
      }

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': formData['email'],
          'fullName': formData['fullName'],
          'phone': formData['phone'],
          'companyName': formData['companyName'],
          'address': formData['address'],
          'city': formData['city'],
          'state': formData['state'],
          'pinCode': formData['pin Code'],
          'yearsOfExperience': formData['yearsOfExperience'],
          'specialization': formData['specialization'],
          'bio': formData['bio'],
          'skills': _selectedSkills,
          'profileCompleted': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ContractorMainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have already registered.")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ContractorMainScreen()),
        );
      }
    }
  }

  Widget _buildSkillsField() {
    return FormBuilderFilterChip<String>(
      name: 'skills',
      decoration: const InputDecoration(
        labelText: 'Select Skills',
        border: InputBorder.none,
      ),
      options: const [
        FormBuilderChipOption(value: 'Skill 1', child: Text('Plumbing')),
        FormBuilderChipOption(value: 'Skill 2', child: Text('Electrical work')),
        FormBuilderChipOption(value: 'Skill 3', child: Text('Carpentry')),
        FormBuilderChipOption(value: 'Skill 4', child: Text('Welding')),
        FormBuilderChipOption(value: 'Skill 5', child: Text('Painting')),
        FormBuilderChipOption(value: 'Skill 6', child: Text('Roofing')),
        FormBuilderChipOption(value: 'Skill 7', child: Text('Masonry')),
        FormBuilderChipOption(value: 'Skill 8', child: Text('Tiling and flooring')),
        FormBuilderChipOption(value: 'Skill 9', child: Text('HVAC installation and repair')),
        FormBuilderChipOption(value: 'Skill 10', child: Text('Operating heavy machinery')),
        FormBuilderChipOption(value: 'Skill 11', child: Text('Scaffolding setup')),
        FormBuilderChipOption(value: 'Skill 12', child: Text('Blueprint reading and interpretation')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one skill';
        }
        return null;
      },
      onChanged: (value) => _selectedSkills = value ?? [],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contractor Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
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
              const SizedBox(height: 24),
              _sectionTitle("Personal Information"),
              FormBuilderTextField(
                name: 'fullName',
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: "Email"),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              FormBuilderTextField(
                name: 'phone',
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(10),
                ]),
              ),
              const SizedBox(height: 24),
              _sectionTitle("Company Information"),
              FormBuilderTextField(
                name: 'companyName',
                decoration: const InputDecoration(labelText: "Company Name"),
              ),
              const SizedBox(height: 24),
              _sectionTitle("Location Information"),
              FormBuilderTextField(
                name: 'address',
                decoration: const InputDecoration(labelText: "Street Address"),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'city',
                decoration: const InputDecoration(labelText: "City"),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'state',
                decoration: const InputDecoration(labelText: "State"),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'pin Code',
                decoration: const InputDecoration(labelText: "Pin Code"),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 24),
              _sectionTitle("Professional Information"),
              FormBuilderTextField(
                name: 'yearsOfExperience',
                decoration: const InputDecoration(labelText: "Years of Experience"),
                validator: FormBuilderValidators.required(),
                keyboardType: TextInputType.number,
              ),
              FormBuilderTextField(
                name: 'specialization',
                decoration: const InputDecoration(labelText: "Specialization"),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 24),
              _sectionTitle("About"),
              FormBuilderTextField(
                name: 'bio',
                decoration: const InputDecoration(labelText: "Bio", helperText: "Min 5 chars, max 500"),
                maxLines: 6,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(5),
                  FormBuilderValidators.maxLength(500),
                ]),
              ),
              const SizedBox(height: 24),
              _sectionTitle("Skills"),
              _buildSkillsField(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Complete Registration"),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}