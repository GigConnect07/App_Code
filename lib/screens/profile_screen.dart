import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:final5/services/ai_editor_service.dart';
import 'worker_profile_screen.dart';
import 'package:final5/services/ai_edit_dialog.dart';
import 'package:final5/services/auth_screen.dart';
import 'package:final5/services/chat_screen.dart';
import 'package:final5/services/contractor_main_screen.dart';
import 'package:final5/services/contractor_profile_page.dart';
import 'package:final5/services/firebase_options.dart';
import 'package:final5/services/job_applications_list_page.dart';
import 'package:final5/services/jods_application_page.dart';
import 'package:final5/services/notifications_page.dart';
import 'package:final5/services/post_job_page.dart';
import 'package:final5/services/posted_jobs_page.dart';
import 'package:final5/services/registration_page.dart';

void main() {
  runApp(const MyApp());
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AIEditorService _aiService = AIEditorService(
    apiKey: 'sk-e9ec1f3394b34704be58dce0a353c49c', // Replace with actual key
  );

  final TextEditingController _aboutController = TextEditingController();
  bool _isGenerating = false;

  Future<void> _handleAIEdit(String section) async {
    // Get user prompt
    final prompt = await AIEditDialog.show(
      context: context,
      sectionName: section,
      currentContent: _aboutController.text,
    );

    if (prompt == null || prompt.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final newContent = await _aiService.generateEdit(
        sectionName: section,
        currentContent: _aboutController.text,
        userPrompt: prompt,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('AI Generated $section'),
          content: SingleChildScrollView(
            child: Text(newContent),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _aboutController.text = newContent);
                Navigator.pop(context);
              },
              child: const Text('Apply Changes'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _aboutController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'About Section',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : () => _handleAIEdit('About'),
              icon: _isGenerating
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Generating...' : 'AI Enhance'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gig-Connect App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          elevation: 1,
        ),
      ),
      home: const ContractorProfileScreen(),
    );
  }
}

class ContractorProfileScreen extends StatefulWidget {
  const ContractorProfileScreen({super.key});

  @override
  State<ContractorProfileScreen> createState() =>
      _ContractorProfileScreenState();
}

class _ContractorProfileScreenState extends State<ContractorProfileScreen> {
  final String documentId = 'Nwvbvv8Zw9N9K7y0yX5c';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> contractorData = {};
  bool isLoading = true;
  bool isEditing = false;
  bool generatingSkills = false;

  // Controllers for editable fields
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _establishedYearController =
      TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  TextEditingController _profileImageUrl = TextEditingController();
  TextEditingController _backgroundImageUrl = TextEditingController();
  bool isEditingAbout = false;

  @override
  void initState() {
    super.initState();
    _fetchContractorData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _companyNameController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _profileImageUrl.dispose();
    _backgroundImageUrl.dispose();
    _establishedYearController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _fetchContractorData() async {
    try {
      final docSnapshot =
          await _firestore.collection('Contractor').doc(documentId).get();

      if (docSnapshot.exists) {
        setState(() {
          contractorData = docSnapshot.data() as Map<String, dynamic>;
          isLoading = false;
          // Add these lines:
          _profileImageUrl = contractorData['profileImageUrl'];
          _backgroundImageUrl = contractorData['backgroundImageUrl'];

          // Set controller values
          _companyNameController.text =
              contractorData['companyName']?.toString() ?? '';
          _industryController.text =
              contractorData['industry']?.toString() ?? '';
          _locationController.text =
              contractorData['location']?.toString() ?? '';
          _cityController.text = contractorData['City']?.toString() ?? '';
          _emailController.text = contractorData['email']?.toString() ?? '';
          _phoneController.text =
              (contractorData['phone'] as num?)?.toInt().toString() ?? '';
          _establishedYearController.text =
              (contractorData['establishedYear'] as num?)?.toInt().toString() ??
                  '';
          // Handle website field properly (could be a DocumentReference or string)
          if (contractorData['website'] is DocumentReference) {
            _websiteController.text =
                (contractorData['website'] as DocumentReference).path;
          } else {
            _websiteController.text =
                contractorData['website']?.toString() ?? '';
          }
          _establishedYearController.text =
              contractorData['establishedYear']?.toString() ?? '';
          _aboutController.text = contractorData['about']?.toString() ??
              'Experienced worker with skills in the trade. Passionate about quality work and customer satisfaction.';
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Contractor profile not found');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error loading data: $e');
    }
  }

  Future<void> _updateContractorData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Create updated data map
      final Map<String, dynamic> updatedData = {
        'companyName': _companyNameController.text,
        'industry': _industryController.text,
        'location': _locationController.text,
        'City': _cityController.text,
        'email': _emailController.text,
        'phone': _phoneController.text.isNotEmpty
            ? int.tryParse(_phoneController.text)
            : null,
        'establishedYear': _establishedYearController.text.isNotEmpty
            ? int.tryParse(_establishedYearController.text)
            : null,
      };

      // Handle website field - keep as DocumentReference if it was one before
      if (contractorData['website'] is DocumentReference) {
        // Leave it as is - don't update
      } else {
        updatedData['website'] = _websiteController.text;
      }
      if (int.tryParse(_phoneController.text) == null) {
        _showSnackBar('Invalid phone number format');
        return;
      }

      await _firestore
          .collection('Contractor')
          .doc(documentId)
          .update(updatedData);

      // Refresh data
      await _fetchContractorData();

      if (mounted) {
        setState(() {
          isEditing = false;
        });
      }

      _showSnackBar('Profile updated successfully');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error updating profile: $e');
    }
  }

  Future<void> _updateAbout() async {
    try {
      await _firestore
          .collection('Contractor')
          .doc(documentId)
          .update({'about': _aboutController.text});

      setState(() {
        isEditingAbout = false;
      });

      _showSnackBar('About section updated successfully');
    } catch (e) {
      _showSnackBar('Error updating about section: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Future<void> _updateCompanyLogo() async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       maxWidth: 800,
  //       maxHeight: 800,
  //     );
  //
  //     if (pickedFile == null) return;
  //
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     // Create a reference to the location you want to upload to in Firebase Storage
  //     final storageRef = _storage.ref().child('company_logos/$documentId.jpg');
  //
  //     // Upload the file
  //     final uploadTask = storageRef.putFile(File(pickedFile.path));
  //
  //     // Wait for upload to complete
  //     await uploadTask;
  //
  //     // Get download URL
  //     final downloadURL = await storageRef.getDownloadURL();
  //
  //     // Update Firestore with new logo URL
  //     await _firestore
  //         .collection('Contractor')
  //         .doc(documentId)
  //         .update({'companyLogo': downloadURL});
  //
  //     // Refresh data
  //     await _fetchContractorData();
  //
  //     _showSnackBar('Company logo updated successfully');
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     _showSnackBar('Error updating company logo: $e');
  //   }
  // }

  Future<void> _addJobPosting() async {
    final TextEditingController jobController = TextEditingController();

    // Store context before async gap
    final BuildContext currentContext = context;

    return showDialog(
      context: currentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Job Posting'),
          content: TextField(
            controller: jobController,
            decoration: const InputDecoration(
              hintText: 'Enter job title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (jobController.text.isEmpty) return;

                try {
                  List<dynamic> currentJobs =
                      List.from(contractorData['jobPostings'] ?? []);
                  currentJobs.add(jobController.text);

                  await _firestore
                      .collection('Contractor')
                      .doc(documentId)
                      .update({'jobPostings': currentJobs});

                  if (mounted) {
                    Navigator.pop(context);
                    await _fetchContractorData();
                    _showSnackBar('Job posting added successfully');
                  }
                } catch (e) {
                  if (mounted) {
                    _showSnackBar('Error adding job posting: $e');
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => isLoading = true);

    try {
      // Upload profile image
      final profileRef = _storage.ref('profile_images/$documentId.jpg');
      await profileRef.putFile(File(pickedFile.path));
      final profileUrl = await profileRef.getDownloadURL();

      // Update Firestore
      await _firestore.collection('Contractor').doc(documentId).update({
        'profileImageUrl': profileUrl,
      });

      await _fetchContractorData();
    } catch (e) {
      _showSnackBar('Error uploading profile image: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateBackgroundImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => isLoading = true);

    try {
      // Upload background image
      final bgRef = _storage.ref('background_images/$documentId.jpg');
      await bgRef.putFile(File(pickedFile.path));
      final bgUrl = await bgRef.getDownloadURL();

      // Update Firestore
      await _firestore.collection('Contractor').doc(documentId).update({
        'backgroundImageUrl': bgUrl,
      });

      await _fetchContractorData();
    } catch (e) {
      _showSnackBar('Error uploading background image: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _removeJobPosting(int index) async {
    try {
      List<dynamic> currentJobs =
          List.from(contractorData['jobPostings'] ?? []);
      if (index >= 0 && index < currentJobs.length) {
        currentJobs.removeAt(index);

        await _firestore
            .collection('Contractor')
            .doc(documentId)
            .update({'jobPostings': currentJobs});

        await _fetchContractorData();
        _showSnackBar('Job posting removed successfully');
      }
    } catch (e) {
      _showSnackBar('Error removing job posting: $e');
    }
  }

  Future<void> _generateSkills() async {
    setState(() {
      generatingSkills = true;
    });

    try {
      // Simulate AI skill generation
      await Future.delayed(const Duration(seconds: 2));

      // Generate skills based on industry
      List<String> generatedSkills = [];

      String industry =
          contractorData['industry']?.toString().toLowerCase() ?? '';

      if (industry.contains('construction')) {
        generatedSkills = [
          'Blueprint Reading',
          'Framing',
          'Drywall Installation',
          'Safety Compliance',
          'Power Tools'
        ];
      } else if (industry.contains('electrical')) {
        generatedSkills = [
          'Circuit Analysis',
          'Voltage Testing',
          'Wiring',
          'Electrical Code Knowledge',
          'Troubleshooting'
        ];
      } else if (industry.contains('plumbing')) {
        generatedSkills = [
          'Pipe Fitting',
          'Leak Detection',
          'Drain Cleaning',
          'Fixture Installation',
          'Water Heater Repair'
        ];
      } else {
        generatedSkills = [
          'Project Management',
          'Problem Solving',
          'Safety Procedures',
          'Quality Control',
          'Team Management'
        ];
      }

      // Update Firestore with generated skills
      await _firestore
          .collection('Contractor')
          .doc(documentId)
          .update({'skills': generatedSkills});

      await _fetchContractorData();
      _showSnackBar('Skills generated successfully');
    } catch (e) {
      _showSnackBar('Error generating skills: $e');
    } finally {
      setState(() {
        generatingSkills = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contractor Profile"),
        actions: [
          if (!isLoading && !isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          if (!isLoading && isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateContractorData,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchContractorData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    _buildProfileDetails(),
                    _buildJobPostings(),
                    const SizedBox(height: 24),
                    _buildMetricsSection(),
                    _buildSimilarProfiles(),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Background Image
        GestureDetector(
          onTap: isEditing ? _updateBackgroundImage : null,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: contractorData['backgroundImageUrl'] != null
                    ? CachedNetworkImageProvider(
                        contractorData['backgroundImageUrl'])
                    : const AssetImage('assets/default_bg.jpg')
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),

        // Profile Image
        Positioned(
          bottom: -50,
          child: GestureDetector(
            onTap: isEditing ? _updateProfileImage : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: contractorData['profileImageUrl'] != null
                        ? CachedNetworkImageProvider(
                            contractorData['profileImageUrl'])
                        : null,
                    child: contractorData['profileImageUrl'] == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildEditBadge(Icons.camera_alt),
                  ),
              ],
            ),
          ),
        ),

        // Background Image Edit Badge
        if (isEditing)
          Positioned(
            top: 16,
            right: 16,
            child: _buildEditBadge(Icons.photo),
          ),
      ],
    );
  }

  Widget _buildEditBadge(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing) ...[
            _buildEditableField('Company Name', _companyNameController),
            _buildEditableField('Industry', _industryController),
            _buildEditableField('Location', _locationController),
            _buildEditableField('City', _cityController),
            _buildEditableField('Email', _emailController),
            _buildEditableField('Website', _websiteController),
            _buildEditableField(
              'Phone',
              _phoneController,
              keyboardType: TextInputType.phone, // Use phone keyboard
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ], // Restrict to numbers
            ),
// For established year field
            _buildEditableField(
              'Established Year',
              _establishedYearController,
              keyboardType: TextInputType.number, // Use number keyboard
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ], // Restrict to numbers
            ),
          ] else ...[
            Center(
              child: Text(
                contractorData['companyName']?.toString() ?? 'Company Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                contractorData['industry']?.toString() ?? 'Industry',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.location_on, 'Location',
                contractorData['location']?.toString() ?? ''),
            _buildInfoRow(Icons.location_city, 'City',
                contractorData['City']?.toString() ?? ''),
            _buildInfoRow(
              Icons.date_range,
              'Established',
              contractorData['establishedYear']?.toString() ?? 'N/A',
            ),
            _buildInfoRow(Icons.assignment_ind, 'Contractor ID',
                (contractorData['website'] as DocumentReference).path),
            _buildInfoRow(Icons.email, 'Email',
                contractorData['email']?.toString() ?? ''),
            _buildInfoRow(
              Icons.phone,
              'Phone',
              contractorData['phone']?.toString() ?? '',
            ),
            _buildInfoRow(
              Icons.web,
              'Website',
              contractorData['website'] is DocumentReference
                  ? (contractorData['website'] as DocumentReference).path
                  : contractorData['website']?.toString() ?? '',
            ),
          ],

          // About Section
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isEditingAbout)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      isEditingAbout = true;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isEditingAbout)
            Column(
              children: [
                TextField(
                  controller: _aboutController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Tell us about your company',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEditingAbout = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _updateAbout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            )
          else
            Text(
              _aboutController.text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType, // Add this optional parameter
    List<TextInputFormatter>? inputFormatters, // Add this optional parameter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType, // Pass keyboard type
        inputFormatters: inputFormatters, // Pass input formatters
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobPostings() {
    final jobPostings = contractorData['jobPostings'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Postings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                  onPressed: _addJobPosting,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (jobPostings != null &&
              jobPostings is List &&
              jobPostings.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                jobPostings.length,
                (index) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Chip(
                      label: Text(jobPostings[index].toString()),
                      backgroundColor: Colors.deepPurple.withAlpha(38),
                    ),
                    if (isEditing)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: GestureDetector(
                          onTap: () => _removeJobPosting(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cancel,
                                size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Text(
              'No job postings available',
              style: TextStyle(
                  color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Projects Completed',
                  contractorData['projectsCompleted']?.toString() ?? '0',
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Rating',
                  contractorData['rating']?.toString() ?? 'N/A',
                  Icons.star,
                  showStars: true,
                  ratingValue:
                      (contractorData['rating'] as num?)?.toDouble() ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon,
      {bool showStars = false, double ratingValue = 0}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(0.1 as int),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showStars && ratingValue > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < ratingValue ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimilarProfiles() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .where('city', isEqualTo: 'Mumbai')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final workers = snapshot.data?.docs ?? [];

        if (workers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: const Text('No workers found in your area'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workers Near You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: workers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final worker =
                        workers[index].data() as Map<String, dynamic>;
                    return SizedBox(
                      width: 180,
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkerProfileScreen(
                                  workerId: workers[index].id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      worker['profileImage'] != null
                                          ? CachedNetworkImageProvider(
                                              worker['profileImage'])
                                          : null,
                                  child: worker['profileImage'] == null
                                      ? const Icon(Icons.person, size: 30)
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  worker['name'] ?? 'Worker',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${worker['hourlyRate']?.toString() ?? '0'}/hr',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  children: (worker['skills'] as List<dynamic>?)
                                          ?.take(2)
                                          .map((skill) => Chip(
                                                label: Text(skill.toString()),
                                                backgroundColor: Colors
                                                    .deepPurple
                                                    .withOpacity(0.1),
                                              ))
                                          .toList() ??
                                      [],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: generatingSkills ? null : _generateSkills,
            icon: generatingSkills
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_fix_high),
            label: Text(
                generatingSkills ? 'Generating...' : 'Generate Skills with AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            label: const Text('Account Settings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
        ],
      ),
    );
  }
}
