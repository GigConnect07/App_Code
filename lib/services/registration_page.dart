import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool showPassword = false;
  bool showConfirmPassword = false;
  File? _profileImage;
  List<String> _selectedSkills = [];

  // Image picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // Form submission logic
  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      debugPrint("Form Submitted: $formData");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful!")),
      );

      // Simulate redirect after a delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  Widget _buildSkillsField() {
    return FormBuilderField(
      name: 'skills',
      validator: (value) {
        // Check if value is null or an empty list
        if (value == null || (value is List && value.isEmpty)) {
          return 'Please select at least one skill';
        }
        return null;
      },
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select Skills',
            border: OutlineInputBorder(),
            errorText: state.errorText,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedSkills.isNotEmpty ? _selectedSkills[0] : null,
            items: ['Skill 1', 'Skill 2', 'Skill 3', 'Skill 4']
                .map((String skill) {
              return DropdownMenuItem<String>(
                value: skill,
                child: Text(skill),
              );
            }).toList(),
            onChanged: (String? newSkill) {
              setState(() {
                if (newSkill != null) {
                  _selectedSkills = [newSkill]; // Set selected skill
                  state.didChange(_selectedSkills); // Update form state
                }
              });
            },
          ),
        );
      },
    );
  }

  /*Widget _buildSkillsField() {
    return FormBuilderField(
      name: 'skills',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one skill';
        }
        return null;
      },
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select Skills',
            border: OutlineInputBorder(),
            errorText: state.errorText,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedSkills.isNotEmpty ? _selectedSkills[0] : null,
            items: ['Skill 1', 'Skill 2', 'Skill 3', 'Skill 4']
                .map((String skill) {
              return DropdownMenuItem<String>(
                value: skill,
                child: Text(skill),
              );
            }).toList(),
            onChanged: (String? newSkill) {
              setState(() {
                if (newSkill != null) {
                  _selectedSkills = [newSkill]; // Set selected skill
                  state.didChange(_selectedSkills); // Update form state
                }
              });
            },
          ),
        );
      },
    );
  }*/

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
              // Profile Image Upload
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

              // Personal Information Section
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

              // Company Information Section
              _sectionTitle("Company Information"),
              FormBuilderTextField(
                name: 'companyName',
                decoration: const InputDecoration(labelText: "Company Name"),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 24),

              // Location Section
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
                name: 'zipCode',
                decoration: const InputDecoration(labelText: "Zip Code"),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 24),

              // Professional Information Section
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

              // About Section
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

              // Skills Section
              _buildSkillsField(),

              const SizedBox(height: 32),

              // Submit Button
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

  // Section title widget
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
