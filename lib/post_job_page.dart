import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({Key? key}) : super(key: key);

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final locationController = TextEditingController();
  final minRateController = TextEditingController();
  final maxRateController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();

  List<String> selectedSkills = [];
  String? jobType;
  String? experienceLevel;
  String? duration;
  String paymentType = 'hourly';
  DateTime? selectedDate;

  final List<String> allSkills = [
    'Carpentry (framing, finishing)',
    'Masonry (bricklaying, concrete finishing)',
    'Plumbing',
    'Electrical work',
    'HVAC installation and repair',
    'Welding',
    'Drywall installation and finishing',
    'Painting',
    'Roofing',
    'Tiling and flooring',
    'Scaffolding setup',
    'Operating heavy machinery (cranes, bulldozers, forklifts)',
    'Blueprint reading and interpretation',
    'Surveying and leveling',
    'Use of hand and power tools',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate() && selectedDate != null && selectedSkills.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('jobs').add({
          'title': titleController.text.trim(),
          'company': companyController.text.trim(),
          'location': locationController.text.trim(),
          'minRate': minRateController.text.trim(),
          'maxRate': maxRateController.text.trim(),
          'description': descriptionController.text.trim(),
          'requirements': requirementsController.text.trim(),
          'skills': selectedSkills,
          'jobType': jobType,
          'experienceLevel': experienceLevel,
          'duration': duration,
          'paymentType': paymentType,
          'startDate': selectedDate,
          'timestamp': FieldValue.serverTimestamp(),
          'contractorId': user.uid,
          'applicants': [],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')),
        );

        _formKey.currentState!.reset();
        setState(() {
          selectedSkills = [];
          selectedDate = null;
          jobType = null;
          experienceLevel = null;
          duration = null;
          paymentType = 'hourly';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
    } else if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
    } else if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Job Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Job Title *'),
                validator: (value) => value!.isEmpty ? 'Enter job title' : null,
              ),
              TextFormField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              DropdownButtonFormField(
                value: jobType,
                decoration: const InputDecoration(labelText: 'Job Type *'),
                items: const [
                  DropdownMenuItem(value: 'fulltime', child: Text('Full-time')),
                  DropdownMenuItem(value: 'parttime', child: Text('Part-time')),
                  DropdownMenuItem(value: 'contract', child: Text('Contract')),
                  DropdownMenuItem(value: 'temporary', child: Text('Temporary')),
                ],
                onChanged: (value) => setState(() => jobType = value.toString()),
                validator: (value) => value == null ? 'Select job type' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Job Location *'),
                validator: (value) => value!.isEmpty ? 'Enter job location' : null,
              ),
              const SizedBox(height: 20),
              const Text("Payment Type"),
              Row(
                children: [
                  Radio(
                    value: 'hourly',
                    groupValue: paymentType,
                    onChanged: (value) => setState(() => paymentType = value!),
                  ),
                  const Text('Hourly Rate'),
                  Radio(
                    value: 'fixed',
                    groupValue: paymentType,
                    onChanged: (value) => setState(() => paymentType = value!),
                  ),
                  const Text('Fixed Price'),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minRateController,
                      decoration: const InputDecoration(labelText: 'Minimum Rate *'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter minimum rate' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: maxRateController,
                      decoration: const InputDecoration(labelText: 'Maximum Rate *'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter maximum rate' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Job Description & Requirements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Job Description *'),
                validator: (value) => value!.isEmpty ? 'Enter job description' : null,
              ),
              TextFormField(
                controller: requirementsController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Requirements'),
              ),

              // 🛠 Multi-select Dropdown for Skills
              const SizedBox(height: 12),
              MultiSelectDialogField(
                items: allSkills.map((skill) => MultiSelectItem<String>(skill, skill)).toList(),
                title: const Text("Select Required Skills"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                buttonIcon: const Icon(Icons.arrow_drop_down),
                buttonText: const Text("Required Skills *"),
                onConfirm: (results) {
                  setState(() {
                    selectedSkills = results.cast<String>();
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Please select skills' : null,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: experienceLevel,
                decoration: const InputDecoration(labelText: 'Experience Level *'),
                items: const [
                  DropdownMenuItem(value: 'entry', child: Text('Entry Level (0-2 years)')),
                  DropdownMenuItem(value: 'intermediate', child: Text('Intermediate (3-5 years)')),
                  DropdownMenuItem(value: 'experienced', child: Text('Experienced (5-10 years)')),
                  DropdownMenuItem(value: 'expert', child: Text('Expert (10+ years)')),
                ],
                onChanged: (value) => setState(() => experienceLevel = value.toString()),
                validator: (value) => value == null ? 'Select experience level' : null,
              ),
              const SizedBox(height: 20),
              const Text("Project Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("Start Date *"),
                subtitle: Text(selectedDate == null
                    ? 'No date selected'
                    : '${selectedDate!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              DropdownButtonFormField(
                value: duration,
                decoration: const InputDecoration(labelText: 'Project Duration *'),
                items: const [
                  DropdownMenuItem(value: 'lessThanWeek', child: Text('Less than a week')),
                  DropdownMenuItem(value: '1-2weeks', child: Text('1-2 weeks')),
                  DropdownMenuItem(value: '2-4weeks', child: Text('2-4 weeks')),
                  DropdownMenuItem(value: '1-3months', child: Text('1-3 months')),
                  DropdownMenuItem(value: '3-6months', child: Text('3-6 months')),
                  DropdownMenuItem(value: '6-12months', child: Text('6-12 months')),
                  DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                ],
                onChanged: (value) => setState(() => duration = value.toString()),
                validator: (value) => value == null ? 'Select project duration' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("Post Job"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
