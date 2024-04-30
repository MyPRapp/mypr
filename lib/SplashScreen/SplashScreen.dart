import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mypr/Pages/HomePage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset("assets/Lottie/Animated_Logo.json"),
      ),
      nextScreen: const HomePage(),
      duration: 0,
      backgroundColor: Colors.black,
      splashIconSize: 600,
    );
  }
}
