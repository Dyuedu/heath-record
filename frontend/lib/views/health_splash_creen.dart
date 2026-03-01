import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/views/login_register_screen.dart';

class HealthSplashScreen extends StatefulWidget {
  const HealthSplashScreen({super.key});

  @override
  State<HealthSplashScreen> createState() => _HealthSplashScreenState();
}

class _HealthSplashScreenState extends State<HealthSplashScreen> {
    @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Health Record',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A438F),
                    ),
                  ),
                  const Text(
                    'MANAGEMENT',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Image.asset('assets/images/heartbeat_line.png', height: 100),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20, bottom: 40),
                    child: Text(
                      'Manage Health. Manage Life.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
