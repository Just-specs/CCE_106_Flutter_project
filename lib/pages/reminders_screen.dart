import 'package:flutter/material.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<String> reminders = [
    'Buy flowers for Mom',
    'Order birthday bouquet',
  ];
  final reminderController = TextEditingController();

  @override
  void dispose() {
    reminderController.dispose();
    super.dispose();
  }

  void _addReminder() {
    if (reminderController.text.isNotEmpty) {
      setState(() {
        reminders.add(reminderController.text);
        reminderController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: reminderController,
              decoration: InputDecoration(
                labelText: 'Add new reminder',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addReminder,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    title: Text(reminders[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          reminders.removeAt(index);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
