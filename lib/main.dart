import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'core/di/injection.dart' as di;
import 'core/constants/routes/app_router.dart';
import 'core/constants/apiconstants/api_constants.dart';
import 'core/services/app_lifecycle_reactor.dart';
import 'core/services/app_master_service.dart';
import 'core/services/session_manager.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart' hide AppMasterService;


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("--- 📩 BACKGROUND NOTIFICATION RECEIVED ---");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");

  try {
    await PendingActionService.checkPendingDeviceActions();
    print("--- ✅ BACKGROUND PENDING ACTIONS EXECUTED SUCCESSFULLY ---");
  } catch (e) {
    print("--- ❌ BACKGROUND PENDING ACTIONS ERROR: $e ---");
  }
}

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

      try {
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
        print('--- 📥 BACKGROUND TASK: LOCATION SYNC STATUS: ${response.statusCode} ---');
      } catch (e) {
        print("❌ Background Location Error: $e");
      }

      try {
        await AppMasterService.sendInstalledApps();
        await PendingActionService.checkPendingDeviceActions();
        print("--- ✅ BACKGROUND SYNC: APPS & PENDING ACTIONS COMPLETED ---");
      } catch (e) {
        print("❌ Background Apps/Actions Sync Error: $e");
      }

      return Future.value(true);
    } catch (e) {
      print("--- ❌ BACKGROUND TASK ERROR ---");
      print("Error: $e");
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _requestPhonePermission();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask(
    "bosoq_background_sync_task",
    "bosoqBackgroundSync",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  await _initializeFCMToken();
  await di.init();

  runApp(const MyApp());
}

Future<void> _requestPhonePermission() async {
  try {
    var status = await Permission.phone.status;
    print("📱 Current Phone Permission Status: $status");
    if (!status.isGranted) {
      status = await Permission.phone.request();
      print("📱 Requested Phone Permission Status: $status");
      if (status.isPermanentlyDenied) {
        print("📱 Phone permission permanently denied. Opening settings...");
        await openAppSettings();
      }
    }
  } catch (e) {
    print("❌ Error requesting phone permission: $e");
  }
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("--- 🔔 FOREGROUND NOTIFICATION RECEIVED ---");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");

      try {
        PendingActionService.checkPendingDeviceActions();
        print("--- ✅ FOREGROUND PENDING ACTIONS EXECUTED ---");
      } catch (e) {
        print("--- ❌ FOREGROUND PENDING ACTIONS ERROR: $e ---");
      }
    });

  } catch (e) {
    print("MAIN.DART - Error fetching FCM token: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleReactor(
      child: MaterialApp.router(
        title: 'LockIt Customer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}