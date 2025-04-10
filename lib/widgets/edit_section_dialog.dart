// widgets/edit_section_dialog.dart
import 'package:flutter/material.dart';

class EditSectionDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String fieldName;

  const EditSectionDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.fieldName,
  });

  @override
  State<EditSectionDialog> createState() => _EditSectionDialogState();
}

class _EditSectionDialogState extends State<EditSectionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.title}'),
      content: TextField(
        controller: _controller,
        maxLines: widget.fieldName == 'bio' ? 5 : 1,
        decoration: InputDecoration(hintText: 'Enter ${widget.title.toLowerCase()}'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}