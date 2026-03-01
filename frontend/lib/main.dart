import 'package:flutter/material.dart';
import 'package:frontend/views/health_splash_creen.dart';

void main() {
  runApp(const HealthRecordApp());
}

class HealthRecordApp extends StatelessWidget {
  const HealthRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HealthSplashScreen(),
    );
  }
}