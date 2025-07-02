import 'package:flutter/material.dart';
import 'dart:async';
import 'package:student_registration/api_service.dart';
import 'reset_password_screen.dart';
import 'chats.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final bool isPasswordResetFlow;

  const OTPScreen({
    super.key,
    required this.email,
    this.isPasswordResetFlow = false,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _otpFields =
  List.generate(4, (_) => TextEditingController());
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
    setState(() => isLoading = true);

    String otp = _otpFields.map((e) => e.text).join();

    if (otp.isEmpty || otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      setState(() => isLoading = false);
      return;
    }

    otpController.text = otp;

    try {
      if (widget.isPasswordResetFlow) {
        var response = await ApiService.verifyResetOtp(widget.email, otp);
        print("🔐 Reset OTP Verification Response: $response");

        if (response["message"] == "OTP Verified") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: widget.email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid OTP, please try again')),
          );
        }
      } else {
        var response = await ApiService.verifyOTP(widget.email, otp);
        print("OTP Verification Response: $response");

        if (response != null &&
            response.containsKey('role') &&
            response.containsKey('access_token')) {
          String userRole = response['role'];

          if (userRole == 'admin' || userRole == 'student') {
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
      }
    } catch (e) {
      print("OTP Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verification failed')),
      );
    }

    setState(() => isLoading = false);
  }

  void resendOTP() async {
    try {
      if (widget.isPasswordResetFlow) {
        await ApiService.sendResetOtp(widget.email);
      } else {
        await ApiService.sendOTP(widget.email);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New OTP sent to your email')),
      );
      startResendCountdown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP: $e')),
      );
    }
  }

  Widget buildOTPField(int index) {
    return SizedBox(
      width: 55,
      child: TextField(
        controller: _otpFields[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF2F3136),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else if (index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3136),
        title: const Text('OTP verification', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'An OTP has been sent to your email. Please enter it below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 30),

            // OTP Fields Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => buildOTPField(index)),
            ),
            const SizedBox(height: 30),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Verify OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Resend Button
            TextButton(
              onPressed: isResendDisabled ? null : resendOTP,
              child: Text(
                isResendDisabled
                    ? 'Resend OTP in $countdown seconds'
                    : 'Resend OTP',
                style: const TextStyle(color: Color(0xFF00AFF4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
