import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Required import
import '../widgets/custom_textfield.dart';

class RegisterDetailsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const RegisterDetailsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  final TextEditingController skillController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String selectedGender = 'Male';
  final List<String> genders = ['Male', 'Female', 'Other'];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: genders.map((String gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => selectedGender = value!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Gender",
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(hint: "Skills", controller: skillController),
            const SizedBox(height: 16),
            CustomTextField(hint: "Location", controller: locationController),
            const SizedBox(height: 16),
            CustomTextField(hint: "Bio", controller: bioController),
            const Spacer(),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              onPressed: () async {
                if (skillController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    bioController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please fill in all fields")),
                  );
                  return;
                }

                setState(() => isLoading = true);

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .add({
                    'name': widget.name,
                    'email': widget.email,
                    'phone': widget.phone,
                    'gender': selectedGender,
                    'skills': skillController.text,
                    'location': locationController.text,
                    'bio': bioController.text,
                    'createdAt': Timestamp.now(),
                    'profileImage': '',
                    'backgroundImage': '',
                    'industries': [],
                    'jobApplications': [],
                    'profileType': 'worker',
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Registration Successful")),
                  );

                  Navigator.popUntil(context, (route) => route.isFirst);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                } finally {
                  setState(() => isLoading = false);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
