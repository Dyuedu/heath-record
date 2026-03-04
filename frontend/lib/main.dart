import 'package:flutter/material.dart';
import 'package:frontend/utils/app_providers.dart';
import 'package:frontend/views/health_splash_creen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  runApp(const HealthRecordApp());
}

class HealthRecordApp extends StatelessWidget {
  const HealthRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.getProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HealthSplashScreen(),
      ),
    );
  }
}
