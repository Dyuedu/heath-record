import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: const Color(0xFF246BFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_hospital, size: 80, color: Color(0xFF246BFF)),
            const SizedBox(height: 16),
            const Text(
              'Welcome Doctor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_box),
              label: const Text('Create Medical Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF246BFF),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/doctor/create-record');
              },
            ),
          ],
        ),
      ),
    );
  }
}
