import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/apiconstants/api_constants.dart';
import '../../../../core/services/session_manager.dart';
import '../models/generate_key_model.dart';

abstract class GenerateKeyRemoteDataSource {
  Future<GenerateKeyModel> generateKeyApi();
  Future<bool> validateCustomerKey(String apiAccessKey);
}

class GenerateKeyRemoteDataSourceImpl implements GenerateKeyRemoteDataSource {
  GenerateKeyRemoteDataSourceImpl();

  @override
  Future<GenerateKeyModel> generateKeyApi() async {
    const url = ApiConstants.generateKeyApi;

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final String fcmToken = await SessionManager.getFcmToken();
    final String clientcode = await SessionManager.getClientCode() ?? '';
    final String customerCode = await SessionManager.getCustomerCode() ?? '';

    final requestBody = {
      "fcmToken": fcmToken,
      "clientcode": clientcode,
      "customerCode": customerCode,
    };

    print('==============================');
    print('URL: $url');
    print('REQUEST BODY: ${jsonEncode(requestBody)}');
    print('==============================');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    print('==============================');
    print('STATUS CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');
    print('==============================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return GenerateKeyModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to generate key. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> validateCustomerKey(String apiAccessKey) async {
    try {
      final url = Uri.parse(ApiConstants.validateCustomerKey);

      final requestBody = {
        "apiacessKey": apiAccessKey,
      };

      print('--- 🚀 VALIDATING CUSTOMER KEY ---');
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

      print('--- 📥 VALIDATE KEY RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final String message = decoded['message'] ?? '';

          if (message.toUpperCase() == "KEY VERIFIED BY RETAILER") {
            return true;
          } else {
            throw Exception(message.isNotEmpty ? message : "KEY NOT VERIFIED BY RETAILER");
          }
        }
      }
      throw Exception("Failed to validate key. Status code: ${response.statusCode}");
    } catch (e) {
      print('--- ❌ VALIDATE KEY ERROR ---');
      print('Error: $e');
      rethrow;
    }
  }
}