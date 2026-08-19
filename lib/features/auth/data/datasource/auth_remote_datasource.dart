import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/apiconstants/api_constants.dart';
import '../../../../core/helper/api_client.dart';
import '../../domain/entities/entities.dart';
import '../models/login_response_model.dart';
import '../models/verify_otp_request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

abstract class AuthRemoteDatasource {
  Future<LoginResponseModel> login({
    required String mobileOrEmailID,
    String password = "",
    String loginType = "Customer",
  });

  Future<LoginResponseModel> sendOtp(String mobileOrEmailID);
  Future<AuthEntity> verifyOtp({
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
    if (_isSendingOtp) {
      return LoginResponseModel(message: "OTP already sending...");
    }
    _isSendingOtp = true;

    try {
      final uri = Uri.parse(ApiConstants.sendOtp);

      final requestBody = {
        "mobileOrEmailID": mobileOrEmailID,
        "otP_Type": "Retailer",
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
    final uri = Uri.parse(ApiConstants.Login);

    final prefs = await SharedPreferences.getInstance();

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
        print("Error fetching dynamic device info: $e");
        deviceId = "UNKNOWN_DEVICE_ID";
        imeiNumber = "UNKNOWN_IMEI";
      }
    }

    final String token = prefs.getString('fcm_token') ?? 'sdfdf';

    final requestBody = {
      "mobileOrEmailID": mobileOrEmailID,
      "password": password,
      "login_Type": loginType,
      "deviceId": deviceId,
      "token": token,
      "imeiNumber": imeiNumber,
    };

    print('--- LOGIN REQUEST ---');
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

    print('--- LOGIN RESPONSE ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      if (responseData['statuss'] == 'False' ||
          responseData['statuss'] == false) {
        throw Exception(responseData['message'] ?? 'Login failed.');
      }

      return LoginResponseModel(
        message: responseData['message'] ?? "Login Successful",
      );
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }

  @override
  Future<LoginResponseModel> verifyOtp({
    required String mobileOrEmail,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiConstants.verifyOtp);

    final requestModel = VerifyOtpRequestModel(
      mobileOrEmail: mobileOrEmail,
      enteredOTP: otp,
    );

    print('--- VERIFY OTP REQUEST (SIGNUP) ---');
    print('URL: $uri');
    print('Request Body: ${jsonEncode(requestModel.toJson())}');

    final response = await ApiClient.post(
      uri,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestModel.toJson()),
    );

    print('--- VERIFY OTP RESPONSE (SIGNUP) ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      if (responseData['statuss'] == 'False' ||
          responseData['statuss'] == false) {
        throw Exception(responseData['message'] ?? 'Incorrect OTP.');
      }

      return LoginResponseModel(
        message: responseData['message'] ?? "OTP Verified Successfully",
      );
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