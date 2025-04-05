import 'package:flutter/material.dart';
import 'user_profile.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  final TextEditingController _searchController = TextEditingController();

  void _searchJobs() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searching for: $query')),
      );
      // TODO: Hook this up with Firestore job search
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 Scrollable content
        ListView(
          padding:
              const EdgeInsets.only(bottom: 80), // Leave space for search bar
          children: [
            // 🔹 Top bar with profile photo + name
            Container(
              color: const Color.fromARGB(255, 178, 158, 233),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage("https://i.imgur.com/OB0y6MR.jpg"),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Your Name",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(username: "User $index"),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage("https://i.imgur.com/OB0y6MR.jpg"),
                          ),
                          const SizedBox(height: 5),
                          Text("User $index",
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Job postings container (static for now)
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

            // Dummy job cards for scroll testing
            ...List.generate(7, (index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text("Job #${index + 1}",
                      style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
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
}
