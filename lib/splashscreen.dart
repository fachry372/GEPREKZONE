import 'package:flutter/material.dart';
import 'dart:async';

import 'package:geprekzone/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
   
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffb31217), Color(0xffe52d27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          
           const Text(
  "GeprekZone",
  style: TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 2,
  ),
),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}