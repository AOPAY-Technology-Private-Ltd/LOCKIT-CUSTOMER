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
import '../../../../core/utils/device_action_channel.dart';
import '../models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

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

      Map<String, List<Map<String, dynamic>>> categorizedApps = {
        "SOCIAL_APPS": [],
        "UPI_APPS": [],
        "GAMING_APPS": [],
        "AUDIO_APPS": [],
        "IMAGE_APPS": [],
        "MAP_APPS": [],
        "NEWS_APPS": [],
        "VIDEO_APPS": [],
        "PRODUCTIVITY_APPS": [],
        "TRUECALLER_APPS": [],
        "UNDEFINED_APPS": [],
      };

      for (var app in apps) {
        String packageName = (app.packageName ?? '').toLowerCase();
        String appName = (app.name ?? '').toLowerCase();

        String targetCategory = "UNDEFINED_APPS";

        if (packageName.contains('whatsapp') || packageName.contains('facebook') || packageName.contains('instagram') || packageName.contains('telegram') || packageName.contains('twitter') || packageName.contains('snapchat')) {
          targetCategory = "SOCIAL_APPS";
        } else if (packageName.contains('upi') || packageName.contains('paytm') || packageName.contains('phonepe') || packageName.contains('gpay') || packageName.contains('google.android.apps.wallet') || packageName.contains('bank')) {
          targetCategory = "UPI_APPS";
        } else if (packageName.contains('game') || packageName.contains('play') || appName.contains('game')) {
          targetCategory = "GAMING_APPS";
        } else if (packageName.contains('audio') || packageName.contains('music') || packageName.contains('spotify') || packageName.contains('gaana') || packageName.contains('wynk')) {
          targetCategory = "AUDIO_APPS";
        } else if (packageName.contains('camera') || packageName.contains('gallery') || packageName.contains('photo') || packageName.contains('image')) {
          targetCategory = "IMAGE_APPS";
        } else if (packageName.contains('map') || packageName.contains('navigation') || packageName.contains('gps')) {
          targetCategory = "MAP_APPS";
        } else if (packageName.contains('news') || packageName.contains('aajtak') || packageName.contains('ndtv')) {
          targetCategory = "NEWS_APPS";
        } else if (packageName.contains('video') || packageName.contains('youtube') || packageName.contains('netflix') || packageName.contains('hotstar') || packageName.contains('prime')) {
          targetCategory = "VIDEO_APPS";
        } else if (packageName.contains('office') || packageName.contains('document') || packageName.contains('pdf') || packageName.contains('productivity')) {
          targetCategory = "PRODUCTIVITY_APPS";
        } else if (packageName.contains('truecaller')) {
          targetCategory = "TRUECALLER_APPS";
        }

        categorizedApps[targetCategory]!.add({
          "appName": app.name ?? '',
          "packageName": app.packageName ?? '',
        });
      }

      List<Map<String, dynamic>> categoriesPayload = [];

      categorizedApps.forEach((catKey, appList) {
        if (appList.isNotEmpty) {
          categoriesPayload.add({
            "category": catKey,
            "apps": appList,
          });
        }
      });

      final requestBody = {
        "createdBy": customerCode,
        "categories": categoriesPayload,
      };

      final url = Uri.parse(ApiConstants.AppMasterService);
      final String encodedBody = jsonEncode(requestBody);

      print('--- 🚀 SENDING CATEGORIZED INSTALLED APPS ---');
      print('URL: $url');
      print('Total Categories: ${categoriesPayload.length}');

      print('--- 📦 REQUEST BODY START ---');
      final pattern = RegExp('.{1,800}');
      pattern.allMatches(encodedBody).forEach((match) => print('BODY PART: ${match.group(0)}'));
      print('--- 📦 REQUEST BODY END ---');

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

      final url = Uri.parse(ApiConstants.DeviceInformationService);
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

class PendingActionService {
  static Future<void> checkPendingDeviceActions() async {
    try {
      final customerCode = await SessionManager.getCustomerCode() ?? '';
      final clientCode = await SessionManager.getClientCode() ?? '';

      if (customerCode.isEmpty || clientCode.isEmpty) {
        print('❌ CustomerCode or ClientCode is empty');
        return;
      }

      final url = Uri.parse(ApiConstants.PendingActionService);

      final requestBody = {
        "customerCode": customerCode,
        "clientcode": clientCode,
      };

      print('--- 🚀 CHECKING PENDING DEVICE ACTIONS ---');
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

      print('--- 📥 PENDING DEVICE ACTIONS RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Pending action API failed');
        return;
      }

      final decoded = jsonDecode(response.body);

      final bool apiStatus = decoded is Map && (decoded['status'] == true || decoded['status'] == 'true');

      if (!apiStatus) {
        print('❌ Pending API status is false');
        return;
      }

      final List dataList = decoded['data'] is List ? decoded['data'] : [];
      print('--- 📊 TOTAL PENDING ACTIONS: ${dataList.length} ---');

      for (final actionItem in dataList) {
        final int rid = int.tryParse(actionItem['rid']?.toString() ?? '0') ?? 0;
        final String notificationCode = actionItem['notificationCode']?.toString() ?? '';
        final List selectedApps = actionItem['selectedApps'] is List ? actionItem['selectedApps'] : [];

        print('🔔 Processing RID: $rid | Notification: $notificationCode');

        bool allAppsExecuted = true;

        for (final app in selectedApps) {
          final String packageName = app['packageName']?.toString() ?? '';
          final String actionType = app['action']?.toString() ?? '';

          print('👉 Executing Package: $packageName | Action: $actionType');

          try {
            await DeviceActionChannel.performAction(
              notificationCode: notificationCode,
              packageName: packageName,
              action: actionType,
            ).timeout(const Duration(seconds: 10));

            print('✅ Successfully executed: $packageName');
          } catch (e) {
            allAppsExecuted = false;
            print('❌ Error executing package $packageName: $e');
          }
        }

        if (rid > 0) {
          print('--- 🔄 INITIATING SERVER UPDATE FOR RID $rid ---');

          final bool isUpdated = await UpdateDeviceActionService.updateDeviceActionStatus(
            rid: rid,
            executionStatus: allAppsExecuted ? "Success" : "Failed",
            failureReason: allAppsExecuted ? "" : "Error executing some apps",
            updatedBy: customerCode,
            devicePin: "",
          );

          print('--- 📥 SERVER UPDATE RESULT FOR RID $rid: $isUpdated ---');
        } else {
          print('❌ RID is invalid ($rid), skipping update API.');
        }
      }
    } catch (e, stackTrace) {
      print('--- ❌ PENDING DEVICE ACTIONS ERROR ---');
      print('Error: $e');
      print('StackTrace: $stackTrace');
    }
  }
}

class AppUninstalledService {
  static Future<void> sendAppUninstalledNotification() async {
    try {
      final clientCode = await SessionManager.getClientCode() ?? '';
      final retailerCode = await SessionManager.getRetailerCode() ?? '';
      final customerCode = await SessionManager.getCustomerCode() ?? '';

      if (customerCode.isEmpty) return;

      final url = Uri.parse(ApiConstants.AppUninstalledService);

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



class UpdateDeviceActionService {
  static Future<bool> updateDeviceActionStatus({
    required int rid,
    required String executionStatus,
    required String failureReason,
    required String updatedBy,
    required String devicePin,
    String iccid = "",
    int subscriptionId = 0,
    String carrierName = "",
    String mcc = "",
    String mnc = "",
    int slotIndex = 0,
  }) async {
    try {
      final url = Uri.parse('https://uatapi.aopay.co.in/api/notification/UpdateDeviceActionStatus');

      final requestBody = {
        "rid": rid,
        "executionStatus": executionStatus,
        "failureReason": failureReason,
        "updatedBy": updatedBy,
        "devicePin": devicePin,
        "iccid": iccid,
        "subscriptionId": subscriptionId,
        "carrierName": carrierName,
        "mcc": mcc,
        "mnc": mnc,
        "slotIndex": slotIndex,
      };

      print('--- 🚀 UPDATING DEVICE ACTION STATUS ---');
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

      print('--- 📥 UPDATE DEVICE STATUS RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          final statusVal = decoded['status']?.toString();
          final successVal = decoded['success'];

          if (successVal == true ||
              successVal == 'true' ||
              statusVal == '200' ||
              statusVal == 'true' ||
              statusVal == 'True' ||
              (decoded['message'] != null && decoded['message'].toString().toLowerCase().contains('success'))) {
            return true;
          }
        }

        if (response.body.toLowerCase().contains("success") || response.body.contains("200")) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('--- ❌ UPDATE DEVICE STATUS ERROR ---');
      print('Error: $e');
      return false;
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
      "imeiNumber": imeiNumber,
    };

    print('--- 🚀 LOGIN REQUEST ---');
    print('URL: $uri');
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await ApiClient.post(
      uri,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('--- 📥 LOGIN RESPONSE ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

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
          await PendingActionService.checkPendingDeviceActions();
          await AppUninstalledService.sendAppUninstalledNotification();
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
  CodeSaveCustomerLocationKit({
    required double latitude,
    required double longitude,
  }) async {
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

      print('--- 🚀 SAVE CUSTOMER LOCATION REQUEST ---');
      print('URL: $uri');
      print('Method: POST');
      print('Headers: ${{'accept': '*/*', 'Content-Type': 'application/json'}}');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await ApiClient.post(
        uri,
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('--- 📥 SAVE CUSTOMER LOCATION RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

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