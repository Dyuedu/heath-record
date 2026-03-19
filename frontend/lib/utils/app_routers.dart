import 'package:flutter/material.dart';
import 'package:frontend/views/appointment/appointment_page.dart';
import 'package:frontend/views/admin/admin_page.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/views/authentication/signup_page.dart';
import 'package:frontend/views/home/home_page.dart';
import 'package:frontend/views/user/link_requests_inbox_page.dart';
import 'package:frontend/views/user/profile_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';

class AppRouter {
  AppRouter._();
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String personalProfile = '/personal-profile';
  static const String appointments = '/appointments';
  static const String medicalRecords = '/medical-records';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String linkRequestsInbox = '/link-requests-inbox';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const UserProfilePage(),
          settings: settings,
        );
      case personalProfile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      case appointments:
        return MaterialPageRoute(
          builder: (_) => const AppointmentPage(),
          settings: settings,
        );
      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminPage(),
          settings: settings,
        );
      case linkRequestsInbox:
        return MaterialPageRoute(
          builder: (_) => const LinkRequestsInboxPage(),
          settings: settings,
        );
      case medicalRecords:
      // return MaterialPageRoute(
      //   builder: (_) => const MedicalRecordsPage(),
      // );
      case notifications:
      // return MaterialPageRoute(
      //   builder: (_) => const NotificationsPage(),
      // );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
