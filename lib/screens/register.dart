import 'package:flutter/material.dart';
import 'register_details.dart';
import '../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(hint: "Email", controller: emailController, inputType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            CustomTextField(hint: "Name", controller: nameController),
            const SizedBox(height: 16),
            CustomTextField(hint: "Phone", controller: phoneController, inputType: TextInputType.phone),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterDetailsScreen(
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    ),
                  ),
                );

              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
