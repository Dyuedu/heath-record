import 'package:flutter/material.dart';
import 'package:frontend/utils/app_providers.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.getProviders(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage()),
    );
  }
}
