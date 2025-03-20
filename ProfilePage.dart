import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String role = '';
  String experience = '';
  String location = '';
  String availability = '';

  void _editField(String fieldName) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        String value = '';
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: TextField(
            onChanged: (text) {
              value = text;
            },
            decoration: InputDecoration(
              hintText: 'Enter $fieldName...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, value);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        switch (fieldName) {
          case 'Role/Skill':
            role = result;
            break;
          case 'Experience':
            experience = result;
            break;
          case 'Location':
            location = result;
            break;
          case 'Availability':
            availability = result;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Icon
            Icon(
              Icons.person,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),

            // Role/Skill
            _buildInfoCard('Role/Skill', role, () => _editField('Role/Skill')),
            SizedBox(height: 10),

            // Work Experience
            _buildInfoCard(
                'Experience', experience, () => _editField('Experience')),
            SizedBox(height: 10),

            // Location
            _buildInfoCard('Location', location, () => _editField('Location')),
            SizedBox(height: 10),

            // Availability
            _buildInfoCard(
                'Availability', availability, () => _editField('Availability')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, VoidCallback onEdit) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue, // Blue background
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Edit (Pencil) Icon
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white, size: 20), // White icon
            onPressed: onEdit,
          ),
          SizedBox(width: 10),

          // Information Bar
          Expanded(
            child: Text(
              value.isEmpty ? 'Enter $label...' : value,
              style: TextStyle(
                fontSize: 18,
                color: value.isEmpty
                    ? Colors.grey[300]
                    : Colors.white, // White text
              ),
            ),
          ),
        ],
      ),
    );
  }
}
