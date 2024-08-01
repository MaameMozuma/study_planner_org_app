import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:study_master/screens/sub-pages/landing.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showSecondText = false;

  @override
  void initState() {
    super.initState();
    // Ensure the second text appears after 2 seconds
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        showSecondText = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'StudyMaster',
                  textStyle: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 63, 23, 1),
                  ),
                  speed: const Duration(milliseconds: 400),
                ),
              ],
              isRepeatingAnimation: false,
              onFinished: () {
                // Ensure second text appears after the first one finishes
                Future.delayed(const Duration(milliseconds: 200), () {
                  setState(() {
                    showSecondText = true;
                  });
                });
              },
            ),
            const SizedBox(height: 5),
            if (showSecondText)
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Master your studies, Master your life',
                    textStyle: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                    duration: const Duration(milliseconds: 2000),
                  ),
                ],
                isRepeatingAnimation: false,
                onFinished: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingPage(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),

    );
  }
}