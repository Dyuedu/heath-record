import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/views/admin/admin_dashboard_page.dart';
import 'package:frontend/views/home/home_page.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _authFuture;

  @override
  void initState() {
    super.initState();
    // QUAN TRỌNG: Chỉ khởi tạo Future 1 lần duy nhất trong initState
    // Sử dụng context.read thay vì watch ở đây để tránh loop
    _authFuture = context.read<AuthViewModel>().isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF246BFF))),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          final authViewModel = context.read<AuthViewModel>();
          if (authViewModel.isAdmin) {
            return const AdminDashboardPage();
          }
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}