import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/pages/ask_user.dart';
import 'package:gig_connect/pages/edit_page.dart';
import 'package:gig_connect/pages/for_you.dart';
import 'package:gig_connect/models/worker_profile.dart';
import 'package:gig_connect/services/worker_profile_service.dart';
import 'profile_page.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int myIndex = 1;
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
      });
    }
  }

  void signUserOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserSelectionPage()),
    );
  }

  void updateProfile(
    String newName,
    String newRole,
    String newInfo,
    String newSkills,
    String newWorkHistory,
  ) async {
    if (_workerProfile != null) {
      final updatedProfile = WorkerProfile(
        uid: _workerProfile!.uid,
        username: newName.isNotEmpty ? newName : _workerProfile!.username,
        role: newRole.isNotEmpty ? newRole : _workerProfile!.role,
        personalInfo:
            newInfo.isNotEmpty ? newInfo : _workerProfile!.personalInfo,
        skills: newSkills.isNotEmpty ? newSkills : _workerProfile!.skills,
        workHistory: newWorkHistory.isNotEmpty
            ? newWorkHistory
            : _workerProfile!.workHistory,
        experience: _workerProfile!.experience,
        location: _workerProfile!.location,
        availability: _workerProfile!.availability,
      );

      await _profileService.saveWorkerProfile(updatedProfile);
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ForYouPage(),
      ProfilePage(
        username: _workerProfile?.username ?? "Username",
        role: _workerProfile?.role ?? "Role/profession",
        personalInfo:
            _workerProfile?.personalInfo ?? "No personal info provided yet.",
        skills: _workerProfile?.skills ?? "No skills added yet.",
        workHistory:
            _workerProfile?.workHistory ?? "No work history provided yet.",
        onEditPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPage(
                onSave: updateProfile,
              ),
            ),
          );
        },
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker's page"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              signUserOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.deepPurpleAccent,
        child: Column(
          children: [
            const DrawerHeader(
              child: Icon(
                Icons.account_circle,
                size: 50,
                color: Colors.white,
              ),
            ),
            const ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title:
                  Text("S E T T I N G", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title:
                  const Text("E D I T", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(
                      onSave: updateProfile,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: pages[myIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurpleAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "For you"),
          BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_rounded), label: "Profile"),
        ],
      ),
    );
  }
}
