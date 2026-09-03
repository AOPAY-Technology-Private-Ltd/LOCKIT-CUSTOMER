import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/apiconstants/api_constants.dart';
import '../../../../core/helper/api_client.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/network/network_service.dart';
import '../models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class AuthRemoteDatasource {
  Future<LoginResponseModel> login({
    required String mobileOrEmailID,
    String password = "",
    String loginType = "Customer",
  });

  Future<LoginResponseModel> sendOtp(String mobileOrEmailID);

  Future<LoginResponseModel> kitVerifyOtp({
    required String mobileOrEmail,
    required String otp,
  });

  Future<void> sendSmsForVerifyMob({
    required String mobnumber,
    required String customerName,
    required String otp,
  });

  Future<bool> saveCustomerLocationKit({
    required double latitude,
    required double longitude,
  });
}

class AppMasterService {
  static Future<void> sendInstalledApps() async {
    try {
      final String customerCode = await SessionManager.getCustomerCode() ?? 'AFC1234';

      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, false);

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

      print('--- 🚀 SENDING INSTALLED APPS ---');
      print('URL: $url');
      print('Total Apps Found: ${appList.length}');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('--- 📥 SAVE APP MASTER RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

    } catch (e) {
      print('--- ❌ SAVE APP MASTER ERROR ---');
      print('Error: $e');
    }
  }
}

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
          const MethodChannel imeiPlatform = MethodChannel('com.bosoq.device_owner/imei');
          final String? nativeImei = await imeiPlatform.invokeMethod<String>('getImei');

          if (nativeImei != null &&
              nativeImei.trim().isNotEmpty &&
              nativeImei.trim() != "UNKNOWN") {
            imeiNumber = nativeImei.trim();
            await prefs.setString('imei_number', imeiNumber);
          }
        } catch (e) {
          print("⚠️ Native IMEI fetch warning: $e");
        }

        try {
          const MethodChannel simChannel = MethodChannel('com.bosoq.device_owner/sim_info');
          final Map<Object?, Object?>? simResult = await simChannel.invokeMethod<Map<Object?, Object?>>('getSimInfo');

          if (simResult != null) {
            carrierName = simResult['carrierName']?.toString() ?? "";
            mcc = simResult['mcc']?.toString() ?? "";
            mnc = simResult['mnc']?.toString() ?? "";
            slotIndex = simResult['slotIndex'] as int? ?? 0;
            subscriptionId = simResult['subscriptionId'] as int? ?? 0;
            serialNumber = simResult['serialNumber']?.toString() ?? "unknown";
          }
        } catch (e) {
          print("⚠️ Native SIM Info fetch warning: $e");
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
        "imeiNumber": "",
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
      print('URL: $url');
      print('IMEI Number: $imeiNumber');
      print('Carrier Name: $carrierName');
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
      print('StackTrace: $stackTrace');
    }
  }
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  bool _isSendingOtp = false;

  @override
  Future<LoginResponseModel> sendOtp(String mobileOrEmailID) async {
    final bool hasConnection = await NetworkService.hasInternet();
    if (!hasConnection) {
      throw Exception('No internet connection');
    }

    if (_isSendingOtp) {
      return LoginResponseModel(message: "OTP already sending...");
    }
    _isSendingOtp = true;

    try {
      final uri = Uri.parse(ApiConstants.sendOtp);

      final requestBody = {
        "mobileOrEmailID": mobileOrEmailID,
        "otP_Type": "Customer",
      };

      print('--- SEND OTP REQUEST ---');
      print('URL: $uri');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        uri,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('--- SEND OTP RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final String backendOtp = responseData['value']?.toString() ?? "1234";

        if (mobileOrEmailID.length == 10) {
          await sendSmsForVerifyMob(
            mobnumber: mobileOrEmailID,
            customerName: "User",
            otp: backendOtp,
          );
        }

        return LoginResponseModel(
          message: responseData['message'] ?? "OTP Sent Successfully",
        );
      } else {
        throw Exception("Failed to send OTP: ${response.body}");
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      _isSendingOtp = false;
    }
  }

  @override
  Future<LoginResponseModel> login({
    required String mobileOrEmailID,
    String password = "",
    String loginType = "Customer",
  }) async {
    final bool hasConnection = await NetworkService.hasInternet();

    if (!hasConnection) {
      throw Exception('No internet connection');
    }

    final uri = Uri.parse(ApiConstants.Login);
    final prefs = await SharedPreferences.getInstance();

    try {
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 1));
        final String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print("📱 APNS Token: $apnsToken");
      }

      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await prefs.setString('fcm_token', fcmToken);
        print("✅ FCM Token fetched successfully");
      }
    } catch (e) {
      print("❌ Error fetching FCM token during login: $e");
    }

    String deviceId = '';
    String imeiNumber = '';

    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;

        try {
          const MethodChannel platform = MethodChannel('com.bosoq.device_owner/imei');
          final String? nativeImei = await platform.invokeMethod<String>('getImei');

          if (nativeImei != null &&
              nativeImei.trim().isNotEmpty &&
              nativeImei.trim() != "UNKNOWN") {
            imeiNumber = nativeImei.trim();
          }
        } catch (e) {
          print("❌ Dynamic IMEI error during login: $e");
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_device_id';
      }

      await prefs.setString('device_id', deviceId);
      await prefs.setString('imei_number', imeiNumber);
    } catch (e) {
      print("❌ Device information error: $e");
      deviceId = "UNKNOWN_DEVICE_ID";
    }

    final String token = prefs.getString('fcm_token') ?? '';

    final requestBody = {
      "mobileOrEmailID": mobileOrEmailID,
      "password": password,
      "login_Type": loginType,
      "deviceId": deviceId,
      "token": token,
      "imeiNumber": "",
    };

    final response = await ApiClient.post(
      uri,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    try {
      final responseData = jsonDecode(response.body);

      if (responseData['statuss'] == 'False' ||
          responseData['statuss'] == false) {
        final String rawMessage = responseData['message']?.toString() ?? '';
        String userMessage = rawMessage;

        if (rawMessage.isEmpty ||
            rawMessage == 'clientCode' ||
            rawMessage.length <= 3) {
          userMessage = 'Something went wrong. Please check your details or try again later.';
        }

        throw Exception(userMessage);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(responseData);
      } else {
        throw Exception("Login failed. Please try again.");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Failed to process login response.");
    }
  }

  @override
  Future<LoginResponseModel> kitVerifyOtp({
    required String mobileOrEmail,
    required String otp,
  }) async {
    try {
      bool hasConnection = await NetworkService.hasInternet();
      if (!hasConnection) {
        throw Exception('No internet connection');
      }

      final uri = Uri.parse(ApiConstants.kitVerifyOtp);
      final requestBody = {
        "mobileOrEmail": mobileOrEmail,
        "enteredOTP": otp,
      };

      final response = await ApiClient.post(
        uri,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == false ||
            responseData['status'] == 'False' ||
            responseData['statuss'] == 'False' ||
            responseData['statuss'] == false) {
          throw Exception(responseData['message'] ?? 'OTP verification failed.');
        }

        final loginResponse = LoginResponseModel.fromJson(responseData);

        if (loginResponse.customerCode != null &&
            loginResponse.customerCode!.isNotEmpty) {
          await SessionManager.createSession(
            customerCode: loginResponse.customerCode!,
            mobileNo: loginResponse.mobileNo ?? mobileOrEmail,
            emailID: loginResponse.emailID ?? '',
            firstName: loginResponse.firstName,
            lastName: loginResponse.lastName,
            retailerCode: loginResponse.retailerCode ?? responseData['retailerCode'],
            clientcode: loginResponse.clientcode ?? responseData['clientcode'],
          );

          await _fetchAndSendLocationAfterLogin();
          await AppMasterService.sendInstalledApps();
          await DeviceInformationService.sendDeviceInformation();
        }

        return loginResponse;
      } else {
        throw Exception("Failed to verify OTP: ${response.body}");
      }
    } catch (e, stackTrace) {
      print('--- ❌ CRITICAL ERROR IN KIT VERIFY OTP ---');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _fetchAndSendLocationAfterLogin() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await saveCustomerLocationKit(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print("❌ Error inside _fetchAndSendLocationAfterLogin: $e");
    }
  }

  @override
  Future<void> sendSmsForVerifyMob({
    required String mobnumber,
    required String customerName,
    required String otp,
  }) async {
    final bool hasConnection = await NetworkService.hasInternet();
    if (!hasConnection) {
      throw Exception('No internet connection');
    }

    final message = "Dear $customerName, Your OTP for Verification is $otp. Please Do Not Share the OTP With Anyone. Thanks For Using BOSOQ BOS CENTER";

    final uri = Uri.parse(ApiConstants.sendSms).replace(
      queryParameters: {
        'apikey': ConstantClass.smsApiKey,
        'senderid': ConstantClass.smsSenderId,
        'templateid': ConstantClass.smsTemplateId,
        'number': mobnumber,
        'message': message,
      },
    );

    final response = await ApiClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Failed to send SMS: ${response.body}");
    }
  }

  @override
  Future<bool> saveCustomerLocationKit({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final customerCode = await SessionManager.getCustomerCode() ?? '';
      final retailerCode = await SessionManager.getRetailerCode() ?? '';
      final clientcode = await SessionManager.getClientCode() ?? '';

      if (customerCode.isEmpty) return false;

      final uri = Uri.parse(ApiConstants.saveCustomerLocationKit);

      final requestBody = {
        "clientcode": clientcode,
        "retailerCode": retailerCode,
        "customerCode": customerCode,
        "latitude": latitude,
        "longitude": longitude,
        "locationTime": DateTime.now().toUtc().toIso8601String(),
      };

      final response = await ApiClient.post(
        uri,
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && (decoded['status'] == true || decoded['status'] == 'True')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('--- ❌ SAVE CUSTOMER LOCATION ERROR ---');
      print('Error: $e');
      return false;
    }
  }
}

class ConstantClass {
  static const String smsApiKey = "KBSxc26XqjoiR7SA";
  static const String smsSenderId = "BOSCNT";
  static const String smsTemplateId = "1207175396979758678";
}