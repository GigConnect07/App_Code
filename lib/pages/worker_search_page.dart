import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gig_connect/pages/view_profile_page.dart';

class WorkerSearchPage extends StatefulWidget {
  const WorkerSearchPage({super.key});

  @override
  State<WorkerSearchPage> createState() => _WorkerSearchPageState();
}

class _WorkerSearchPageState extends State<WorkerSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _searchQuery = '';
  String _locationFilter = '';
  final bool _showLocationFilter = false;

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showLocationFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Location'),
        content: TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: 'Enter location...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _locationFilter = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _locationController.clear();
              setState(() {
                _locationFilter = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Workers'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showLocationFilterDialog,
            tooltip: 'Filter by location',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by skills or role...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                if (_locationFilter.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Chip(
                          label: Text('Location: $_locationFilter'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            _locationController.clear();
                            setState(() {
                              _locationFilter = '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('worker_profiles')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final workers = snapshot.data?.docs ?? [];

                // Filter workers based on case-insensitive search and location
                final filteredWorkers = workers.where((doc) {
                  final worker = doc.data() as Map<String, dynamic>;
                  final skills =
                      worker['skills']?.toString().toLowerCase() ?? '';
                  final role = worker['role']?.toString().toLowerCase() ?? '';
                  final location =
                      worker['location']?.toString().toLowerCase() ?? '';
                  final searchLower = _searchQuery.toLowerCase();
                  final locationLower = _locationFilter.toLowerCase();

                  bool matchesSearch = _searchQuery.isEmpty ||
                      skills.contains(searchLower) ||
                      role.contains(searchLower);

                  bool matchesLocation = _locationFilter.isEmpty ||
                      location.contains(locationLower);

                  return matchesSearch && matchesLocation;
                }).toList();

                if (filteredWorkers.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty && _locationFilter.isEmpty
                          ? 'No workers found'
                          : 'No workers found matching your criteria',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker =
                        filteredWorkers[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: null,
                          backgroundColor: Colors.purple,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          worker['username'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker['role'] ?? 'No role specified'),
                            if (worker['skills'] != null)
                              Text(
                                'Skills: ${worker['skills']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (worker['location'] != null)
                              Text(
                                'Location: ${worker['location']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewProfilePage(
                                userId: filteredWorkers[index].id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
