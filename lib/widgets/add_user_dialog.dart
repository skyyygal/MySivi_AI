import 'package:flutter/material.dart';

class AddUserDialog extends StatelessWidget {
  const AddUserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text("Add New User"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Enter full name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, name);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
