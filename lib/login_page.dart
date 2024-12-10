import 'package:doctor_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String verificationId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            SizedBox(height: 20),
            if (verificationId.isNotEmpty)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter OTP"),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: verificationId.isEmpty ? _verifyPhone : _verifyOTP,
              child:
                  Text(verificationId.isEmpty ? "Verify Phone" : "Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Fluttertoast.showToast(msg: "Phone number verified automatically!");
        _navigateToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        Fluttertoast.showToast(msg: "Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
        });
        Fluttertoast.showToast(msg: "Verification code sent!");
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _verifyOTP() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: _otpController.text.trim(),
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Fluttertoast.showToast(msg: "Phone number verified!");
      _navigateToHome();
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP: $e");
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const Homepage(
                username: 'Abc',
              )),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  void navigateToLogin(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Homepage(username: 'Abc')));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Column(
        children: [
          Center(child: Text("Welcome to the Hospital Management App!")),
          ElevatedButton(
              onPressed: () => navigateToLogin(context),
              child: Text("Login Page"))
        ],
      ),
    );
  }
}
