import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/models/job_posting.dart';
import 'package:gig_connect/services/job_posting_service.dart';
import 'package:gig_connect/pages/view_profile_page.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  final TextEditingController _searchController = TextEditingController();
  final JobPostingService _jobPostingService = JobPostingService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _searchJobs() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searching for: $query')),
      );
      // TODO: Implement job search functionality
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 Scrollable content
        ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // 🔹 Top bar with profile photo + name
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('worker_profiles')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                final username = snapshot.data?['username'] ?? 'Your Name';
                return Container(
                  color: const Color.fromARGB(255, 178, 158, 233),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage("https://i.imgur.com/OB0y6MR.jpg"),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        username,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // 🔹 Horizontal scroller for other profiles
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "People you may like",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('worker_profiles')
                    .where('uid',
                        isNotEqualTo: currentUserId) // Exclude current user
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final profiles = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profile =
                          profiles[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewProfilePage(
                                userId: profiles[index].id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    "https://i.imgur.com/OB0y6MR.jpg"),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                profile['username'] ?? 'User',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Job postings container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Job Postings",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Job postings list
            StreamBuilder<List<JobPosting>>(
              stream: _jobPostingService.getJobPostings(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jobPostings = snapshot.data ?? [];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobPostings.length,
                  itemBuilder: (context, index) {
                    final job = jobPostings[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${job.company} • ${job.location}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              job.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                    '${job.minRate} - ${job.maxRate} ${job.paymentType}'),
                                const SizedBox(width: 16),
                                const Icon(Icons.work, size: 16),
                                const SizedBox(width: 4),
                                Text(job.skills),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 16),
                                const SizedBox(width: 4),
                                Text(job.duration),
                                const SizedBox(width: 16),
                                const Icon(Icons.person, size: 16),
                                const SizedBox(width: 4),
                                Text(job.experienceLevel),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Posted ${_getTimeAgo(job.timestamp)}',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),

        // 🔹 Fixed Search Bar
        Positioned(
          bottom: 10,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search for jobs...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchJobs,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
