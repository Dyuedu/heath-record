import 'package:flutter/material.dart';
import 'package:frontend/utils/app_providers.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:frontend/utils/auth_wrapper.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(
    MultiProvider(providers: AppProviders.getProviders(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      // Sử dụng AuthWrapper thay vì gọi logic trực tiếp ở đây
      home: const AuthWrapper(),
    );
  }
}
