import 'package:flutter/material.dart';
import 'package:gig_connect/models/worker_profile.dart';
import 'package:gig_connect/services/worker_profile_service.dart';

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
  final WorkerProfileService _profileService = WorkerProfileService();
  WorkerProfile? _workerProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.getWorkerProfile();
    if (mounted) {
      setState(() {
        _workerProfile = profile;
        if (profile != null) {
          nameController.text = profile.username;
          roleController.text = profile.role;
          infoController.text = profile.personalInfo;
          skillsController.text = profile.skills;
          workHistoryController.text = profile.workHistory;
        }
      });
    }
  }

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
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    infoController.dispose();
    skillsController.dispose();
    workHistoryController.dispose();
    super.dispose();
  }
}
