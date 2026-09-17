import 'package:flutter/services.dart';

class DeviceActionChannel {
  static const MethodChannel _channel = MethodChannel('com.bosoq.device_owner/actions');

  static Future<void> performAction({
    required String notificationCode,
    required String packageName,
    required String action,
  }) async {
    try {
      final result = await _channel.invokeMethod('performAction', {
        "notificationCode": notificationCode,
        "packageName": packageName,
        "action": action,
      });
      print("--- 📱 NATIVE ACTION RESULT: $result ---");
    } catch (e) {
      print("--- ❌ NATIVE ACTION ERROR: $e ---");
    }
  }
}