import 'package:flutter/material.dart';

/// Example usage:
///
/// void main() {
///   runApp(MaterialApp(
///     home: Scaffold(
///       appBar: AppBar(title: Text('Example Page')),
///       body: Center(child: Text('Main content here')),
///       bottomNavigationBar: RecruiterNavigationBar(
///         currentTab: 'home',
///         onTabChange: (tab) {
///           // Handle tab change
///         },
///       ),
///     ),
///   ));
/// }

class RecruiterNavigationBar extends StatelessWidget {
  final String currentTab;
  final Function(String) onTabChange;

  const RecruiterNavigationBar({
    Key? key,
    required this.currentTab,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This container replicates:
    // - fixed bottom positioning
    // - white background
    // - top border
    // - horizontal and vertical padding
    return Container(
      // Position at the bottom using SafeArea to avoid system UI overlap
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      // Use a Row to space items evenly
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavButton(
            icon: Icons.home,
            label: 'Home',
            isActive: currentTab == 'home',
            onPressed: () => onTabChange('home'),
          ),
          NavButton(
            icon: Icons.people, // or any suitable icon for 'network'
            label: 'My Network',
            isActive: currentTab == 'network',
            onPressed: () => onTabChange('network'),
          ),
          NavButton(
            icon: Icons.notifications,
            label: 'Notifications',
            isActive: currentTab == 'notifications',
            onPressed: () => onTabChange('notifications'),
          ),
          NavButton(
            icon: Icons.work, // or Icons.business_center
            label: 'My Jobs',
            isActive: currentTab == 'jobs',
            onPressed: () => onTabChange('jobs'),
          ),
        ],
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const NavButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You can adjust these colors to match your brand (text-recruiter-blue, etc.)
    final activeColor = const Color(0xFF0056D2);
    final inactiveColor = Colors.grey.shade500;

    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 60, // Similar to w-16 in Tailwind (~64px), adjust as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24, // Similar to w-6 h-6 in Tailwind
            ),
            const SizedBox(height: 4), // Spacing between icon and label
            Text(
              label,
              style: TextStyle(
                fontSize: 12, // Similar to text-xs
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              // This small dot replicates the w-1.5 h-1.5 circle in your React code
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
