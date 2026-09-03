import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class DeviceInformationService {
  static Future<void> sendDeviceInformation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String imeiNumber = "";
      String carrierName = "";
      String mcc = "";
      String mnc = "";
      int slotIndex = 0;
      int subscriptionId = 0;
      String serialNumber = "unknown";

      if (Platform.isAndroid) {
        try {
          var phoneStatus = await Permission.phone.status;
          var locationStatus = await Permission.location.status;

          if (!phoneStatus.isGranted) {
            phoneStatus = await Permission.phone.request();
          }
          if (!locationStatus.isGranted) {
            locationStatus = await Permission.location.request();
          }

          if (phoneStatus.isGranted) {
            const MethodChannel imeiPlatform = MethodChannel('com.bosoq.device_owner/imei');
            final String? nativeImei = await imeiPlatform.invokeMethod<String>('getImei');

            if (nativeImei != null &&
                nativeImei.trim().isNotEmpty &&
                nativeImei.trim() != "UNKNOWN") {
              imeiNumber = nativeImei.trim();
              await prefs.setString('imei_number', imeiNumber);
            }

            const MethodChannel simChannel = MethodChannel('com.bosoq.device_owner/sim_info');
            final dynamic simResult = await simChannel.invokeMethod('getSimInfo');

            if (simResult is Map) {
              carrierName = simResult['carrierName']?.toString() ?? "";
              mcc = simResult['mcc']?.toString() ?? "";
              mnc = simResult['mnc']?.toString() ?? "";
              slotIndex = simResult['slotIndex'] is int ? simResult['slotIndex'] : int.tryParse(simResult['slotIndex']?.toString() ?? '0') ?? 0;
              subscriptionId = simResult['subscriptionId'] is int ? simResult['subscriptionId'] : int.tryParse(simResult['subscriptionId']?.toString() ?? '0') ?? 0;
              serialNumber = simResult['serialNumber']?.toString() ?? "unknown";

              print("✅ SIM Info fetched successfully: Carrier=$carrierName, MCC=$mcc, MNC=$mnc");
            } else {
              print("⚠️ simResult is not a Map: $simResult");
            }
          } else {
            print("❌ Phone state permission denied.");
          }
        } catch (e) {
          print("❌ Native Exception in DeviceInformationService: $e");
        }
      }

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo? androidInfo;
      if (Platform.isAndroid) {
        androidInfo = await deviceInfo.androidInfo;
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appVersion = packageInfo.version;

      final requestBody = {
        "imeiNumber": imeiNumber,
        "deviceID": androidInfo?.id ?? "",
        "manufacturer": androidInfo?.manufacturer ?? "",
        "model": androidInfo?.model ?? "",
        "brand": androidInfo?.brand ?? "",
        "deviceName": androidInfo?.device ?? "",
        "osVersion": androidInfo?.version.release ?? "",
        "sdkVersion": androidInfo?.version.sdkInt.toString() ?? "",
        "appVersion": appVersion,
        "serialNumber": serialNumber,
        "iccid": "",
        "subscriptionId": subscriptionId,
        "carrierName": carrierName,
        "mcc": mcc,
        "mnc": mnc,
        "slotIndex": slotIndex
      };

      final url = Uri.parse('https://uatapi.aopay.co.in/api/V1/AopayFinance/GetDeviceInformation');
      final String encodedBody = jsonEncode(requestBody);

      print('--- 🚀 SENDING DEVICE INFORMATION ---');
      print('Request Body: $encodedBody');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: encodedBody,
      );

      print('--- 📥 DEVICE INFO RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

    } catch (e, stackTrace) {
      print('--- ❌ DEVICE INFO ERROR ---');
      print('Error: $e');
    }
  }
}