import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_navigation_page.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  ConfirmationResult? confirmationResult;

  bool codeSent = false;
  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  Future<void> sendCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      confirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(
        phoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        codeSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code sent')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send code: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> verifyCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      await confirmationResult!.confirm(codeController.text.trim());

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid code: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.phone_android,
              size: 70,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify your phone number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your phone number to receive a verification code.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+16015551234',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            if (codeSent)
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : codeSent
                        ? verifyCode
                        : sendCode,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(codeSent ? 'Verify Code' : 'Send Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}