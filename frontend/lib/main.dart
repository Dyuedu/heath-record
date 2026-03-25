import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/app_providers.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/auth_wrapper.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(providers: AppProviders.getProviders(), child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (_) {
      // Ignore malformed initial deep-link.
    }

    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'healthrecord' || uri.host != 'activation') {
      return;
    }

    final status = (uri.queryParameters['status'] ?? '').toLowerCase();
    final message = (uri.queryParameters['message'] ?? '').trim();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRouter.activationResult,
      (route) => false,
      arguments: {
        'success': status == 'success',
        'message': message,
      },
    );
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AuthWrapper(),
    );
  }
}
