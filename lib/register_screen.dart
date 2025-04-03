import 'package:flutter/material.dart';
import 'package:student_registration/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = 'student';

  void register() async {
    var response = await ApiService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      role,
    );
    if (response['message'] == 'User registered') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center( // Center the content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // Ensures scrollability if needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // Ensures the content is centered vertically
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
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
                ElevatedButton(
                    onPressed: register, child: const Text('Register')),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

