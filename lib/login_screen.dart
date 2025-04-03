import 'package:flutter/material.dart';
import 'package:student_registration/api_service.dart';
import 'package:student_registration/register_screen.dart';
import 'otpscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = 'student';

  void login() async {
    var response = await ApiService.login(emailController.text, passwordController.text);

    print("Login Response: $response"); // Debugging Response

    if (response != null && response.containsKey("message")) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(email: emailController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center( // Center the content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // Ensures content is scrollable if needed
            child: Column(
              mainAxisSize: MainAxisSize.min, // Centers vertically within available space
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                DropdownButton<String>(
                  value: role,
                  items: ['student', 'admin'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      role = newValue!;
                    });
                  },
                ),
                ElevatedButton(onPressed: login, child: const Text('Login')),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
