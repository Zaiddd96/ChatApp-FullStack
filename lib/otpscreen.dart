import 'package:flutter/material.dart';
import 'dart:async';
import 'package:student_registration/api_service.dart';
import 'chats.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  const OTPScreen({super.key, required this.email});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool isResendDisabled = true;
  int countdown = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startResendCountdown();
  }

  void startResendCountdown() {
    setState(() {
      isResendDisabled = true;
      countdown = 60;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        setState(() {
          isResendDisabled = false;
          timer.cancel();
        });
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void verifyOTP() async {
    setState(() {
      isLoading = true;
    });

    String otp = otpController.text.trim();

    if (otp.isEmpty || otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    var response = await ApiService.verifyOTP(widget.email, otp);

    print("OTP Verification Response: $response");

    if (response != null && response.containsKey('role') && response.containsKey('access_token')) {
      String userRole = response['role'];

      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UsersScreen()),
        );
      } else if (userRole == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UsersScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid role received')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP, please try again')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void resendOTP() async {
    await ApiService.sendOTP(widget.email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New OTP sent to your email')),
    );
    startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'An OTP has been sent to your email. Please enter it below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 8),
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyOTP,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify OTP'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: isResendDisabled ? null : resendOTP,
              child: Text(isResendDisabled
                  ? 'Resend OTP in $countdown seconds'
                  : 'Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}