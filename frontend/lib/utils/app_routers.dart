import 'package:flutter/material.dart';
import '../views/home/home_screen.dart';


class AppRouter {
  AppRouter._();

  // Route names
  static const String home = '/';
  static const String booking = '/booking';
  static const String appointment = '/appointment';
  static const String followUp = '/follow-up';
  static const String medicalHistory = '/medical-history';
  static const String payment = '/payment';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case booking:
        // return MaterialPageRoute(builder: (_) => const BookingScreen());
      case appointment:
        // return MaterialPageRoute(builder: (_) => const AppointmentScreen());
      case followUp:
        // return MaterialPageRoute(builder: (_) => const FollowUpScreen());
      case medicalHistory:
        // return MaterialPageRoute(builder: (_) => const MedicalHistoryScreen());
      case payment:
        // return MaterialPageRoute(builder: (_) => const PaymentScreen());
      case profile:
        // return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
