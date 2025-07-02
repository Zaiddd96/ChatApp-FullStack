import 'package:flutter/material.dart';
import 'package:student_registration/api_service.dart';
import 'package:student_registration/otpscreen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  void sendResetOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => errorText = "Email is required");
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final response = await ApiService.sendResetOtp(email);
      if (response["message"] == "OTP sent for password reset") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              email: email,
              isPasswordResetFlow: true, // You’ll use this inside OTP screen logic
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorText = "Failed to send OTP. Please try again.";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D31), // Discord-like background
      appBar: AppBar(
        title: Text('Forgot Password',style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1F22),
        elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "We will send a 4-digit OTP to your registered email address. Please check your inbox and enter the code on the next screen.",
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 46),

            const Text(
              " Enter your registered email",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Email",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF404249),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Text(errorText!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendResetOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Discord button color
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send OTP", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}