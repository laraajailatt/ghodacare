// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:app_ghoda/constants/app_constants.dart';
import 'package:app_ghoda/utils/shared_pref_util.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    // Simulate loading delay
    await Future.delayed(AppConstants.splashDuration);
    
    if (!mounted) return;
    
    // Check if it's the first time opening the app
    final isFirstTime = await SharedPrefUtil.isFirstTime();
    
    if (isFirstTime) {
      // Navigate to onboarding screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      // Check if user is logged in
      final isLoggedIn = await SharedPrefUtil.isLoggedIn();
      
      if (isLoggedIn) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // Navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo 
            Image.asset(
              'assets/images/logoapp.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              AppConstants.appName,
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Tagline
            Text(
              AppConstants.appTagline,
              style: const TextStyle(
                color: AppConstants.textLightColor,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}