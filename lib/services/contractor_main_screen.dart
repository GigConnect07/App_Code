import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'contractor_profile_page.dart';
import 'post_job_page.dart';
import 'notifications_page.dart';
import 'auth_screen.dart';
import 'job_applications_list_page.dart';

class ContractorMainScreen extends StatefulWidget {
  const ContractorMainScreen({Key? key}) : super(key: key);

  @override
  State<ContractorMainScreen> createState() => _ContractorMainScreenState();
}

class _ContractorMainScreenState extends State<ContractorMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ContractorProfilePage(),
    const PostJobPage(),
    const JobApplicationsListPage(),
    const NotificationsPage(),
  ];

  final List<String> _titles = [
    'Profile',
    'Post Job',
    'Job Applications',
    'Notifications',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Post Job',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Job Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
