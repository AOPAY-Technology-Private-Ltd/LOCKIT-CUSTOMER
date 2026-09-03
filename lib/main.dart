import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'core/di/injection.dart' as di;
import 'core/constants/routes/app_router.dart';
import 'core/constants/apiconstants/api_constants.dart';
import 'core/services/session_manager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final customerCode = await SessionManager.getCustomerCode() ?? '';
      final retailerCode = await SessionManager.getRetailerCode() ?? '';
      final clientcode = await SessionManager.getClientCode() ?? '';

      if (customerCode.isEmpty) {
        return Future.value(false);
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final uri = Uri.parse(ApiConstants.saveCustomerLocationKit);
      final requestBody = {
        "clientcode": clientcode,
        "retailerCode": retailerCode,
        "customerCode": customerCode,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "locationTime": DateTime.now().toUtc().toIso8601String(),
      };

      final response = await http.post(
        uri,
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && (decoded['status'] == true || decoded['status'] == 'True')) {
          return Future.value(true);
        }
      }
      return Future.value(false);
    } catch (e) {
      print("Background Task Error: $e");
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await _initializeFCMToken();

  await di.init();

  runApp(const MyApp());
}

Future<void> _initializeFCMToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null && fcmToken.isNotEmpty) {
      await prefs.setString('fcm_token', fcmToken);
      print("MAIN.DART - Real FCM Token successfully saved: $fcmToken");
    } else {
      print("MAIN.DART - FCM Token is null or empty");
    }
  } catch (e) {
    print("MAIN.DART - Error fetching FCM token: $e");
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