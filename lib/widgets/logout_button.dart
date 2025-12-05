import 'package:flutter/material.dart';
import '../pages/login_screen.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool isLoggingOut = false;

  void _logout() async {
    setState(() {
      isLoggingOut = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoggingOut = false;
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoggingOut ? null : _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade200,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: isLoggingOut
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple))
          : Text('Logout', style: TextStyle(color: Colors.white)),
    );
  }
}
