import 'package:flutter/material.dart';
import 'package:frontend/views/appointment/appointment_page.dart';
import 'package:frontend/views/admin/admin_dashboard_page.dart';
import 'package:frontend/views/admin/admin_user_management_page.dart';
import 'package:frontend/views/admin/admin_pending_list_page.dart';
import 'package:frontend/views/admin/admin_create_account_page.dart';
import 'package:frontend/views/admin/admin_profile_page.dart';
import 'package:frontend/views/authentication/activation_result_page.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/views/authentication/signup_page.dart';
import 'package:frontend/views/home/home_page.dart';
import 'package:frontend/views/user/link_requests_inbox_page.dart';
import 'package:frontend/views/user/profile_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';
import 'package:frontend/views/doctor/doctor_schedule_page.dart';
import 'package:frontend/views/patient/patient_book_appointment_page.dart';

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
  static const String adminDashboard = '/admin-dashboard';
  static const String adminUserManagement = '/admin-user-management';
  static const String adminAccountApproval = '/admin-account-approval';
  static const String adminPendingList = '/admin-pending-list';
  static const String adminCreateAccount = '/admin-create-account';
  static const String linkRequestsInbox = '/link-requests-inbox';
  static const String adminProfile = '/admin-profile';
  static const String doctorSchedule = '/doctor-schedule';
  static const String patientBookAppointment = '/patient-book-appointment';
  static const String activationResult = '/activation-result';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final activationRoute = _tryBuildActivationRouteFromIncomingRoute(settings);
    if (activationRoute != null) {
      return activationRoute;
    }

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
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
          settings: settings,
        );
      case adminUserManagement:
        return MaterialPageRoute(
          builder: (_) => const AdminUserManagementPage(),
          settings: settings,
        );
      case adminPendingList:
        return MaterialPageRoute(
          builder: (_) => const AdminPendingListPage(),
          settings: settings,
        );
      case adminCreateAccount:
        return MaterialPageRoute(
          builder: (_) => const AdminCreateAccountPage(),
          settings: settings,
        );
      case linkRequestsInbox:
        return MaterialPageRoute(
          builder: (_) => const LinkRequestsInboxPage(),
          settings: settings,
        );
      case adminProfile:
        return MaterialPageRoute(
          builder: (_) => const AdminProfilePage(),
          settings: settings,
        );
      case doctorSchedule:
        return MaterialPageRoute(
          builder: (_) => const DoctorSchedulePage(),
          settings: settings,
        );
      // case patientBookAppointment:
      //   return MaterialPageRoute(
      //     builder: (_) => const PatientBookAppointmentPage(),
      //     settings: settings,
      //   );
      case activationResult:
        final args = settings.arguments as Map<String, dynamic>?;
        final success = args?['success'] == true;
        final message = (args?['message']?.toString() ?? '').trim();
        return MaterialPageRoute(
          builder: (_) => ActivationResultPage(
            success: success,
            message: message.isEmpty
                ? (success ? 'Tai khoan da duoc kich hoat.' : 'Khong the kich hoat tai khoan.')
                : message,
          ),
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

  static Route<dynamic>? _tryBuildActivationRouteFromIncomingRoute(
    RouteSettings settings,
  ) {
    final name = (settings.name ?? '').trim();
    if (name.isEmpty) {
      return null;
    }

    // Android can pass deep-link queries as initial route, e.g. /?status=success...
    final looksLikeQueryRoute = name.startsWith('/?');
    final looksLikeActivationPath = name.startsWith('/activation');
    if (!looksLikeQueryRoute && !looksLikeActivationPath) {
      return null;
    }

    final uri = Uri.tryParse(name);
    if (uri == null) {
      return null;
    }

    final status = (uri.queryParameters['status'] ?? '').toLowerCase();
    final message = (uri.queryParameters['message'] ?? '').trim();
    if (status.isEmpty && message.isEmpty) {
      return null;
    }

    final success = status == 'success';
    final resolvedMessage = message.isEmpty
        ? (success
            ? 'Tai khoan da duoc kich hoat.'
            : 'Khong the kich hoat tai khoan.')
        : message;

    return MaterialPageRoute(
      builder: (_) => ActivationResultPage(
        success: success,
        message: resolvedMessage,
      ),
      settings: settings,
    );
  }
}
