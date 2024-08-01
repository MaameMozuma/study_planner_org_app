import 'package:flutter/material.dart';
import 'package:study_master/screens/sub-pages/log_in.dart';
import 'package:study_master/screens/sub-pages/sign_up.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
        child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/landing.png'),
            const SizedBox(height: 130),
            CustomNormButton(
              text: 'Log In',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
            const SizedBox(height: 30),
            CustomNormButton(
              text: 'Sign Up',
              textColor: const Color.fromRGBO(255, 63, 23, 1),
              buttonColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
              },
            ),
          ],),
      ),
      ),
    );
  }
}