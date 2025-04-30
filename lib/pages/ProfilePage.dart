import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: Form(
            key: formKey,
            child: TextFormField(
              onChanged: (text) {
                value = text;
              },
              keyboardType: fieldName == 'Phone' ? TextInputType.phone : TextInputType.text,
              inputFormatters: fieldName == 'Phone' 
                ? [FilteringTextInputFormatter.digitsOnly] 
                : null,
              validator: fieldName == 'Phone' 
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Please enter 10 digit phone number';
                    }
                    return null;
                  }
                : null,
              decoration: InputDecoration(
                hintText: 'Enter $fieldName...',
                errorText: null,
              ),
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
                if (formKey.currentState?.validate() ?? true) {
                  Navigator.pop(context, value);
                }
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
      appBar: AppBar(
        title: Center(child: Text("Profile Page")),
        backgroundColor: Colors.transparent,
      ),
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
