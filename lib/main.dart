import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection.dart' as di;
import 'core/constants/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await _initializeFCMToken();

  await di.init();

  runApp(const MyApp());
}

Future<void> _initializeFCMToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    String fcmToken = "YOUR_HARDCODED_FCM_TOKEN_HERE_ABC123XYZ";

    await prefs.setString('fcm_token', fcmToken);
    print("MAIN.DART - Hardcoded FCM Token successfully saved: $fcmToken");

  } catch (e) {
    print("MAIN.DART - Error saving hardcoded token: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LockIt Customer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}