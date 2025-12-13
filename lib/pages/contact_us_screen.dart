import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final nameController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (nameController.text.isNotEmpty && messageController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message sent!')),
      );
      nameController.clear();
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFE6E6FA), // Lavender
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E6FA), Colors.white, Color(0xFFF5F5F5)], // Lavender, white, grey
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: TextStyle(color: Color(0xFF212121)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFB2EBF2)), borderRadius: BorderRadius.all(Radius.circular(16))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF448AFF)), borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Your Message',
                  labelStyle: TextStyle(color: Color(0xFF212121)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFB2EBF2)), borderRadius: BorderRadius.all(Radius.circular(16))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF448AFF)), borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 28),
              Center(
                child: ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7C4DFF), // Modern visible purple
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 3,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    child: Text('Send Message', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}