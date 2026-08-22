import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/apiconstants/api_constants.dart';
import '../../../../core/helper/api_client.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/network/network_service.dart';
import '../models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print("APNS Token: $apnsToken");
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await prefs.setString('fcm_token', fcmToken);
        print("FCM Token fetched successfully: $fcmToken");
      }
    } catch (e) {
      print("Error fetching FCM token during login: $e");
    }

    String deviceId = prefs.getString('device_id') ?? '';
    String imeiNumber = prefs.getString('imei_number') ?? '';

    if (deviceId.isEmpty || imeiNumber.isEmpty) {
      try {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
          imeiNumber = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'ios_device_id';
          imeiNumber = iosInfo.identifierForVendor ?? 'ios_imei_placeholder';
        }

        await prefs.setString('device_id', deviceId);
        await prefs.setString('imei_number', imeiNumber);
      } catch (e) {
        deviceId = "UNKNOWN_DEVICE_ID";
        imeiNumber = "UNKNOWN_IMEI";
      }
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

    print('--- LOGIN API REQUEST ---');
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

    print('--- LOGIN API RESPONSE ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    try {
      final responseData = jsonDecode(response.body);

      if (responseData['statuss'] == 'False' || responseData['statuss'] == false) {
        String rawMessage = responseData['message']?.toString() ?? '';

        String userMessage = rawMessage;
        if (rawMessage.isEmpty || rawMessage == 'clientCode' || rawMessage.length <= 3) {
          userMessage = 'Something went wrong. Please check your details or try again later.';
        }

        throw Exception(userMessage);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel(
          message: responseData['message'] ?? "Login Successful",
        );
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
    final bool hasConnection = await NetworkService.hasInternet();
    if (!hasConnection) {
      throw Exception('No internet connection');
    }

    final uri = Uri.parse(ApiConstants.kitVerifyOtp);

    final requestBody = {
      "mobileOrEmail": mobileOrEmail,
      "enteredOTP": otp,
    };

    print('--- KIT VERIFY OTP REQUEST ---');
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

    print('--- KIT VERIFY OTP RESPONSE ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

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
        );
      }

      return loginResponse;
    } else {
      throw Exception("Failed to verify OTP: ${response.body}");
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

    print('--- SEND SMS API REQUEST ---');
    print('URL: $uri');

    final response = await ApiClient.get(uri);

    print('--- SEND SMS API RESPONSE ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception("Failed to send SMS: ${response.body}");
    }
  }
}

class ConstantClass {
  static const String smsApiKey = "KBSxc26XqjoiR7SA";
  static const String smsSenderId = "BOSCNT";
  static const String smsTemplateId = "1207175396979758678";
}