import 'dart:async';
import 'package:study_master/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_master/screens/sub-pages/log_in.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _authController.sendEmailVerification();
    timer = Timer.periodic(
        const Duration(seconds: 3), (_) => checkEmailVerified(context));
  }

  checkEmailVerified(context) async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle,
                      color: Color.fromRGBO(255, 63, 23, 1), size: 50),
                  SizedBox(height: 15),
                  Text(
                    'Success',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                ],
              ),
              titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              content: const Text(
                  textAlign: TextAlign.center,
                  'Congratulations! You have  completed your registration.'),
              contentTextStyle: const TextStyle(
                  color: Color.fromRGBO(66, 66, 66, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.normal),
              actions: [
                CustomNormButton(
                  text: 'Done',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );

      timer?.cancel();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/images/verification.png',
                  width: 170, height: 170),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify your email address',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              textAlign: TextAlign.center,
              'A verification link has been sent to your email address. Please click on the link to verify your email address.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              textAlign: TextAlign.center,
              'Verifying email......',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Didn\'t receive the email?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    try {
                      FirebaseAuth.instance.currentUser
                          ?.sendEmailVerification();
                    } catch (e) {
                      debugPrint('$e');
                    }
                  },
                  child: const Text(
                    'Resend email',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 63, 23, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
