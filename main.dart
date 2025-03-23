import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recruiter Profile App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

/// MainScreen holds the bottom navigation bar and switches between 5 pages.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Each index in the bottom nav bar corresponds to one of these screens
  final List<Widget> _screens = [
    const HomeScreen(),         // index 0
    const GrowNetworkPage(),    // index 1
    const NotificationsPage(),  // index 2
    const JobsPage(),           // index 3
    const SettingsPage(),       // index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grow Network',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// HOME SCREEN
//////////////////////////////////////////////////////////////////////////////

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// HomeScreen has the user profile at the top, then a TabBar (About, Jobs, For You)
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data
  String recruiterName = "Adam Constructions";
  String companyName = "AdamBuild Inc.";
  String rating = "4.5 Ratings";
  String description = "Lorem ipsum description.";

  // For the About tab
  String aboutMe = "Hello! I specialize in helping hardworking professionals like you "
      "find stable and well-paying jobs in industries such as construction, "
      "manufacturing, logistics, and skilled trades.";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A custom AppBar with a search field & a placeholder icon
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.all(0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // Could show a menu or something else
              },
              icon: const Icon(Icons.account_circle),
            ),
          ],
        ),
        // No bottom here; we'll place the TabBar below the profile header
      ),
      body: Column(
        children: [
          // Profile Header
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Background (placeholder color)
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text("Background Image", style: TextStyle(color: Colors.black54)),
                  ),
                ),
                // Card with user info
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue,
                            child: Text(
                              recruiterName.isNotEmpty ? recruiterName[0] : "A",
                              style: const TextStyle(fontSize: 24, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recruiterName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(companyName, style: const TextStyle(color: Colors.black54)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.orangeAccent, size: 16),
                                    const SizedBox(width: 4),
                                    Text(rating, style: const TextStyle(color: Colors.blue)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(description, style: const TextStyle(color: Colors.black87)),
                                const SizedBox(height: 8),
                                // Replace 'Message' button with 'Grow Your Network'
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to GrowNetworkPage (bottom nav index = 1)
                                    final mainState = context.findAncestorStateOfType<_MainScreenState>();
                                    mainState?._onItemTapped(1);
                                  },
                                  child: const Text("Grow Your Network"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // TabBar placed under the profile section
          Container(
            color: Colors.grey.shade200,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "About"),
                Tab(text: "Jobs"),
                Tab(text: "For You"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ABOUT
                _buildAboutTab(),
                // JOBS
                _buildJobsTab(),
                // FOR YOU
                _buildForYouTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(aboutMe),
    );
  }

  Widget _buildJobsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          Text(
            "Job Applications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // You can list job items here
          ListTile(
            title: Text("Senior Welder"),
            subtitle: Text("MetaWorks Construction • \$30-\$35/hr\nPosted: 2 days ago"),
            trailing: Text("Edit"),
          ),
          ListTile(
            title: Text("Electrician Apprentice"),
            subtitle: Text("PowerTech Systems • \$18-\$22/hr\nPosted: 1 week ago"),
            trailing: Text("Edit"),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "More Profiles For You",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: const [
              ListTile(
                title: Text("Sarah Johnson"),
                subtitle: Text("Project Manager at BuildBetter Contractors\n12 mutual connections"),
              ),
              ListTile(
                title: Text("Michael Chen"),
                subtitle: Text("Master Electrician at PowerFlow Electric\n8 mutual connections"),
              ),
              ListTile(
                title: Text("Jessica Smith"),
                subtitle: Text("HR Director at TechBuild Industries\n5 mutual connections"),
              ),
              ListTile(
                title: Text("Robert Williams"),
                subtitle: Text("Construction Supervisor at United Building Corp\n15 mutual connections"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// GROW NETWORK PAGE (Premium subscription, etc.)
//////////////////////////////////////////////////////////////////////////////
class GrowNetworkPage extends StatelessWidget {
  const GrowNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grow Your Network"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Upgrade to Our Premium Plan!",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              "Get exclusive features:\n- Priority job matching\n- Detailed analytics\n- Personalized support",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Show subscription flow
              },
              child: const Text("Upgrade Now"),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// NOTIFICATIONS PAGE
//////////////////////////////////////////////////////////////////////////////
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("New job posted for Construction Supervisor"),
            subtitle: Text("2 hours ago"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Sarah Johnson commented on your post"),
            subtitle: Text("5 hours ago"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("You have a new follower"),
            subtitle: Text("1 day ago"),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// JOBS PAGE
//////////////////////////////////////////////////////////////////////////////
class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jobs"),
      ),
      body: const Center(
        child: Text("List of all available jobs here."),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// SETTINGS PAGE
//////////////////////////////////////////////////////////////////////////////
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. back option
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // 2. account preferences
          ListTile(
            title: const Text("Account Preferences"),
            leading: const Icon(Icons.person),
            onTap: () {
              // Open account preferences page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountPreferencesPage()),
              );
            },
          ),
          // 3. sign in
          ListTile(
            title: const Text("Sign-In & Security"),
            leading: const Icon(Icons.lock),
            onTap: () {
              // Open sign-in security page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInSecurityPage()),
              );
            },
          ),
          // 4. visibility
          ListTile(
            title: const Text("Visibility"),
            leading: const Icon(Icons.visibility),
            onTap: () {
              // Open visibility page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisibilityPage()),
              );
            },
          ),
          // 5. notifications
          ListTile(
            title: const Text("Notifications"),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // Open notifications settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsSettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// SUB-PAGES for Settings
//////////////////////////////////////////////////////////////////////////////

class AccountPreferencesPage extends StatelessWidget {
  const AccountPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Preferences"),
      ),
      body: const Center(
        child: Text("Here you can manage your account preferences."),
      ),
    );
  }
}

class SignInSecurityPage extends StatelessWidget {
  const SignInSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign-In & Security"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Email & Phone"),
            subtitle: const Text("Add or edit your email/phone"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Change Password"),
            subtitle: const Text("Update your password"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Two-Step Verification"),
            subtitle: const Text("Enable or disable 2FA"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("App Lock"),
            subtitle: const Text("Enable or disable app lock"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class VisibilityPage extends StatelessWidget {
  const VisibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // You can expand each item to a new screen or add toggles
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visibility"),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Profile viewing options"),
            subtitle: Text("Your name and headline"),
          ),
          ListTile(
            title: Text("Page visit visibility"),
            subtitle: Text("On"),
          ),
          ListTile(
            title: Text("Edit your public profile"),
            subtitle: Text("Control who can see or download your email, etc."),
          ),
          ListTile(
            title: Text("Who can see your connections"),
            subtitle: Text("On"),
          ),
          ListTile(
            title: Text("Who can see members you follow"),
            subtitle: Text("Anyone on LinkedIn"),
          ),
          ListTile(
            title: Text("Who can see your last name"),
            subtitle: Text("Representing your organizations and interests: On"),
          ),
          ListTile(
            title: Text("Page owners exporting your data"),
            subtitle: Text("Off"),
          ),
          ListTile(
            title: Text("Profile discovery using email address"),
            subtitle: Text("Anyone"),
          ),
          ListTile(
            title: Text("Profile discovery using phone number"),
            subtitle: Text("Everyone"),
          ),
          ListTile(
            title: Text("Blocking"),
            subtitle: Text("Manage blocked users"),
          ),
        ],
      ),
    );
  }
}

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Show toggles or sub-pages for each notification category
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications Settings"),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Hiring someone"),
            trailing: Icon(Icons.toggle_on, color: Colors.blue, size: 40),
          ),
          ListTile(
            title: Text("Connecting with others"),
            trailing: Icon(Icons.toggle_on, color: Colors.blue, size: 40),
          ),
          ListTile(
            title: Text("Network catch-up updates"),
            trailing: Icon(Icons.toggle_off, color: Colors.grey, size: 40),
          ),
          ListTile(
            title: Text("Posting and commenting"),
            trailing: Icon(Icons.toggle_on, color: Colors.blue, size: 40),
          ),
          ListTile(
            title: Text("Messaging"),
            trailing: Icon(Icons.toggle_on, color: Colors.blue, size: 40),
          ),
          ListTile(
            title: Text("Groups"),
            trailing: Icon(Icons.toggle_off, color: Colors.grey, size: 40),
          ),
          ListTile(
            title: Text("Pages"),
            trailing: Icon(Icons.toggle_on, color: Colors.blue, size: 40),
          ),
          ListTile(
            title: Text("Attending events"),
            trailing: Icon(Icons.toggle_off, color: Colors.grey, size: 40),
          ),
          ListTile(
            title: Text("News and reports"),
            trailing: Icon(Icons.toggle_on, color: Colors.blue, size: 40),
          ),
          ListTile(
            title: Text("Updating your profile"),
            trailing: Icon(Icons.toggle_on, color: Colors.blue, size: 40),
          ),
          ListTile(
            title: Text("Verifications"),
            trailing: Icon(Icons.toggle_off, color: Colors.grey, size: 40),
          ),
        ],
      ),
    );
  }
}
