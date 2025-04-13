import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  final Function(String, String, String, String, String) onSave;

  const EditPage({super.key, required this.onSave});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController infoController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController workHistoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildEditableField("Name", nameController),
              const SizedBox(height: 20),
              _buildEditableField("Role/Profession", roleController),
              const SizedBox(height: 20),
              _buildEditableField("Personal Info", infoController, maxLines: 3),
              const SizedBox(height: 20),
              _buildEditableField("Skills", skillsController, maxLines: 2),
              const SizedBox(height: 20),
              _buildEditableField("Work History", workHistoryController,
                  maxLines: 4),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                onPressed: () {
                  widget.onSave(
                    nameController.text,
                    roleController.text,
                    infoController.text,
                    skillsController.text,
                    workHistoryController.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Row(
      crossAxisAlignment:
          maxLines == 1 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Icon(Icons.edit, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
