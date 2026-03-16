import 'package:flutter/material.dart';
import 'package:frontend/views/appointment/appointment_page.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/views/authentication/signup_page.dart';
import 'package:frontend/views/home/home_page.dart';
import 'package:frontend/views/user/profile_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';
import 'package:frontend/views/doctor/doctor_dashboard_page.dart';
import 'package:frontend/views/doctor/create_medical_record_page.dart';

class AppRouter {
  AppRouter._();
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String doctorDashboard = '/doctor-dashboard';
  static const String createMedicalRecord = '/doctor/create-record';
  static const String personalProfile = '/personal-profile';
  static const String appointments = '/appointments';
  static const String medicalRecords = '/medical-records';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage(),
        settings: settings
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage(),
        settings: settings
        );
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage(),
        settings: settings
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const UserProfilePage(),
        settings: settings
        );
      case personalProfile:
        return MaterialPageRoute(builder: (_) => const ProfilePage(),
        settings: settings
        );
      case appointments:
        return MaterialPageRoute(
          builder: (_) => const AppointmentPage(),
          settings: settings
        );
      case medicalRecords:
        // return MaterialPageRoute(
        //   builder: (_) => const MedicalRecordsPage(),
        // );
      case notifications:
        // return MaterialPageRoute(
        //   builder: (_) => const NotificationsPage(),
        // );
      case doctorDashboard:
        return MaterialPageRoute(
          builder: (_) => const DoctorDashboardPage(),
          settings: settings
        );
      case createMedicalRecord:
        return MaterialPageRoute(
          builder: (_) => const CreateMedicalRecordPage(),
          settings: settings
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
