import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/models/worker_profile.dart';
import 'package:gig_connect/pages/applied_jobs_page.dart';
import 'package:gig_connect/pages/chat_home_page.dart';
import 'package:gig_connect/pages/edit_page.dart';
import 'package:gig_connect/pages/for_you.dart';
import 'package:gig_connect/pages/messages_page.dart';
import 'package:gig_connect/pages/profile_page.dart';
import 'package:gig_connect/pages/worker_notifications_page.dart';
import 'package:gig_connect/services/worker_profile_service.dart';
import 'package:gig_connect/pages/ask_user.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int myIndex = 1;
  final WorkerProfileService _profileService = WorkerProfileService();
  WorkerProfile? _workerProfile;
  bool _hasNotifications = false;
  Set<String> _viewedNotifications = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _checkNotifications();
    _loadViewedNotifications();
  }

  Future<void> _loadViewedNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('worker_profiles')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        // Create the document if it doesn't exist
        await FirebaseFirestore.instance
            .collection('worker_profiles')
            .doc(currentUser.uid)
            .set({
          'viewedNotifications': [],
          'uid': currentUser.uid,
        });
        setState(() {
          _viewedNotifications = {};
        });
      } else {
        final data = doc.data() as Map<String, dynamic>;
        final viewed = data['viewedNotifications'] as List<dynamic>? ?? [];
        setState(() {
          _viewedNotifications = Set<String>.from(viewed);
        });
      }
    } catch (e) {
      print('Error loading viewed notifications: $e');
      setState(() {
        _viewedNotifications = {};
      });
    }
  }

  Future<void> _markNotificationsAsViewed() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('worker_profiles')
          .doc(currentUser.uid)
          .update({
        'viewedNotifications': _viewedNotifications.toList(),
      });
    } catch (e) {
      print('Error marking notifications as viewed: $e');
    }
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.getWorkerProfile();
    if (mounted) {
      setState(() {
        _workerProfile = profile;
      });
    }
  }

  void _checkNotifications() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Check for job application status notifications
    FirebaseFirestore.instance
        .collection('jobs')
        .where('applicants', arrayContains: currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      bool hasNewNotifications = false;
      for (var doc in snapshot.docs) {
        final jobData = doc.data();
        final selectedApplicants =
            jobData['selectedApplicants'] as List<dynamic>? ?? [];
        final rejectedApplicants =
            jobData['rejectedApplicants'] as List<dynamic>? ?? [];

        if ((selectedApplicants.contains(currentUser.uid) ||
                rejectedApplicants.contains(currentUser.uid)) &&
            !_viewedNotifications.contains(doc.id)) {
          hasNewNotifications = true;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _hasNotifications = hasNewNotifications;
        });
      }
    });

    // Check for job invite notifications
    FirebaseFirestore.instance
        .collection('notifications')
        .where('workerId', isEqualTo: currentUser.uid)
        .where('type', isEqualTo: 'job_invite')
        .where('status', isEqualTo: 'pending')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _hasNotifications = _hasNotifications || snapshot.docs.isNotEmpty;
        });
      }
    });
  }

  void _navigateToNotifications() {
    // Mark all current notifications as viewed
    FirebaseFirestore.instance
        .collection('jobs')
        .where('applicants',
            arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        final jobData = doc.data();
        final selectedApplicants =
            jobData['selectedApplicants'] as List<dynamic>? ?? [];
        final rejectedApplicants =
            jobData['rejectedApplicants'] as List<dynamic>? ?? [];

        if (selectedApplicants
                .contains(FirebaseAuth.instance.currentUser?.uid) ||
            rejectedApplicants
                .contains(FirebaseAuth.instance.currentUser?.uid)) {
          _viewedNotifications.add(doc.id);
        }
      }
      _markNotificationsAsViewed();
    });

    setState(() {
      _hasNotifications = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkerNotificationsPage(),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserSelectionPage()),
        );
      }
    }
  }

  void updateProfile(
    String newName,
    String newRole,
    String newInfo,
    String newSkills,
    String newWorkHistory,
  ) {
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

      _profileService.saveWorkerProfile(updatedProfile);
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

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Worker's page"),
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatHomePage(),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: _navigateToNotifications,
                  icon: const Icon(Icons.notifications),
                ),
                if (_hasNotifications)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              onPressed: () {
                _logout();
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
              Stack(
                children: [
                  ListTile(
                    leading: const Icon(Icons.work, color: Colors.white),
                    title: const Text("A P P L I E D  J O B S",
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppliedJobsPage(),
                        ),
                      );
                    },
                  ),
                  if (_hasNotifications)
                    Positioned(
                      left: 40,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              Stack(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.notifications, color: Colors.white),
                    title: const Text("N O T I F I C A T I O N S",
                        style: TextStyle(color: Colors.white)),
                    onTap: _navigateToNotifications,
                  ),
                  if (_hasNotifications)
                    Positioned(
                      left: 40,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.white),
                title: const Text("M E S S A G E S",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessagesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text("E D I T",
                    style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
