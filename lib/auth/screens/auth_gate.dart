import 'dart:io';

import 'package:flutter/material.dart';
import 'package:student_registration/auth/screens/login_screen.dart';
import '../../services/biometric_auth.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final authService = LocalAuthService();
    bool isAuthenticated = await authService.authenticateUser();

    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF2F3136), // Dark grey
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          title: const Text("Authentication Failed"),
          content: const Text("Biometric authentication failed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _authenticate(); // Retry
              },
              child: const Text(
                "Retry",
                style: TextStyle(color: Color(0xFF00AFF4)), // Light blue
              ),
            ),
            TextButton(
              onPressed: () => exit(0),
              child: const Text(
                "Exit",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        )
      );
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      body: Center(
        child: _isChecking
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Authentication required",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
