import 'dart:convert';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/session_manager.dart';

class AppMasterService {
  static Future<void> sendInstalledApps() async {
    try {
      final String customerCode = await SessionManager.getCustomerCode() ?? 'AFC1234';

      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);

      List<Map<String, dynamic>> appList = apps.map((app) {
        return {
          "appName": app.name ?? '',
          "packageName": app.packageName ?? '',
        };
      }).toList();

      final requestBody = {
        "createdBy": customerCode,
        "categories": [
          {
            "category": "INSTALLED_APPS",
            "apps": appList,
          }
        ]
      };

      final url = Uri.parse('https://uatapi.aopay.co.in/api/notification/SaveAppMaster');

      final String encodedBody = jsonEncode(requestBody);

      print('--- 🚀 SENDING INSTALLED APPS ---');
      print('URL: $url');
      print('Total Apps Found: ${appList.length}');

      final pattern = RegExp('.{1,800}');
      pattern.allMatches(encodedBody).forEach((match) => print('BODY PART: ${match.group(0)}'));

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: encodedBody,
      );

      print('--- 📥 SAVE APP MASTER RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Bodydd: ${response.body}');

    } catch (e) {
      print('--- ❌ SAVE APP MASTER ERROR ---');
      print('Error: $e');
    }
  }
}