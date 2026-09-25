import 'package:flutter/services.dart';

class DeviceActionChannel {
  static const MethodChannel _channel = MethodChannel('com.bosoq.device_owner/actions');

  // Ab yeh function list of apps bhi accept karega
  static Future<void> performAction({
    required String notificationCode,
    String? packageName,
    String? action,
    List<Map<String, dynamic>>? appActions,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        "notificationCode": notificationCode,
      };

      if (appActions != null && appActions.isNotEmpty) {
        arguments["appActions"] = appActions;
      } else if (packageName != null && action != null) {
        arguments["packageName"] = packageName;
        arguments["action"] = action;
      }

      final result = await _channel.invokeMethod('performAction', arguments);
      print("--- 📱 NATIVE ACTION RESULT: $result ---");
    } catch (e) {
      print("--- ❌ NATIVE ACTION ERROR: $e ---");
    }
  }
}