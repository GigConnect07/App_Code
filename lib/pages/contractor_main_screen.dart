import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gig_connect/pages/auth_page.dart';
import 'package:gig_connect/pages/ask_user.dart';

import 'contractor_profile_page.dart';
import 'post_job_page.dart';
import 'notifications_page.dart';

import 'posted_jobs_page.dart';

class ContractorMainScreen extends StatefulWidget {
  const ContractorMainScreen({super.key});

  @override
  State<ContractorMainScreen> createState() => _ContractorMainScreenState();
}

class _ContractorMainScreenState extends State<ContractorMainScreen> {
  int _selectedIndex = 0;
  bool _hasNewApplications = false;
  Set<String> _viewedApplications = {};

  final List<Widget> _pages = [
    const ContractorProfilePage(),
    const PostJobPage(),
    const PostedJobsPage(),
    const NotificationsPage(),
  ];

  final List<String> _titles = [
    'Profile',
    'Post Job',
    'Posted Jobs',
    'Notifications',
  ];

  @override
  void initState() {
    super.initState();
    _loadViewedApplications();
    _checkNewApplications();
  }

  Future<void> _loadViewedApplications() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('contractor_profiles')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        // Create the document if it doesn't exist
        await FirebaseFirestore.instance
            .collection('contractor_profiles')
            .doc(currentUser.uid)
            .set({
          'viewedApplications': [],
          'uid': currentUser.uid,
        });
        setState(() {
          _viewedApplications = {};
        });
      } else {
        final data = doc.data() as Map<String, dynamic>;
        final viewed = data['viewedApplications'] as List<dynamic>? ?? [];
        setState(() {
          _viewedApplications = Set<String>.from(viewed);
        });
      }
    } catch (e) {
      print('Error loading viewed applications: $e');
      setState(() {
        _viewedApplications = {};
      });
    }
  }

  Future<void> _markApplicationsAsViewed() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('contractor_profiles')
          .doc(currentUser.uid)
          .update({
        'viewedApplications': _viewedApplications.toList(),
      });
    } catch (e) {
      print('Error marking applications as viewed: $e');
    }
  }

  void _checkNewApplications() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('jobs')
        .where('contractorId', isEqualTo: currentUser.uid)
        .where('applicants', isNotEqualTo: [])
        .snapshots()
        .listen((snapshot) {
          bool hasNewApps = false;
          for (var doc in snapshot.docs) {
            if (!_viewedApplications.contains(doc.id)) {
              hasNewApps = true;
              break;
            }
          }

          if (mounted) {
            setState(() {
              _hasNewApplications = hasNewApps;
            });
          }
        });
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      // Notifications tab
      // Mark all current applications as viewed
      FirebaseFirestore.instance
          .collection('jobs')
          .where('contractorId',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('applicants', isNotEqualTo: [])
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              _viewedApplications.add(doc.id);
            }
            _markApplicationsAsViewed();
          });

      setState(() {
        _hasNewApplications = false;
      });
    }

    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
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
          title: Text(_titles[_selectedIndex]),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              label: 'Post Job',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Posted Jobs',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (_hasNewApplications)
                    Positioned(
                      right: 0,
                      top: 0,
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
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}
