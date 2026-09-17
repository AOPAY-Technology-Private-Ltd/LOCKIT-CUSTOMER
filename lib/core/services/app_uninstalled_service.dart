import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:lockit_customer/core/services/session_manager.dart';

class AppUninstalledService {
  static Future<void> sendAppUninstalledNotification() async {
    try {
      final clientCode = await SessionManager.getClientCode() ?? '';
      final retailerCode = await SessionManager.getRetailerCode() ?? '';
      final customerCode = await SessionManager.getCustomerCode() ?? '';

      if (customerCode.isEmpty) return;

      final url = Uri.parse('https://uatapi.aopay.co.in/api/notification/CustomerAppUninstalled');

      final requestBody = {
        "clientCode": clientCode,
        "retailerCode": retailerCode,
        "customerCode": customerCode,
        "appName": "LockitCustomer",
        "packageName": "com.aopay.lockitCustomer",
        "eventTime": DateTime.now().toUtc().toIso8601String(),
      };

      print('--- 🚀 SENDING APP UNINSTALLED NOTIFICATION ---');
      print('URL: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('--- 📥 APP UNINSTALLED RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      print('--- ❌ APP UNINSTALLED ERROR ---');
      print('Error: $e');
    }
  }
}