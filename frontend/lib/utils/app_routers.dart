import 'package:flutter/material.dart';
import 'package:frontend/views/appointment/appointment_page.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/views/authentication/signup_page.dart';
import 'package:frontend/views/home/home_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';

class AppRouter {
  AppRouter._();
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String appointments = '/appointments';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const UserProfilePage());
      case appointments:
        return MaterialPageRoute(
          builder: (_) => const AppointmentPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
