import 'dart:convert';
import '../../../../core/constants/apiconstants/api_constants.dart';
import '../../../../core/helper/api_client.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/network/network_service.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfileModel> fetchUserProfile();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  @override
  Future<UserProfileModel> fetchUserProfile() async {
    final bool hasConnection = await NetworkService.hasInternet();
    if (!hasConnection) {
      throw Exception('No internet connection');
    }

    final String? customerCode = await SessionManager.getCustomerCode();

    if (customerCode == null || customerCode.isEmpty) {
      throw Exception("Customer code not found in session. Please login again.");
    }

    final uri = Uri.parse(ApiConstants.getUpdateCustomerKitProfile);

    final requestBody = {
      "mode": "GET",
      "customerType": "Customer",
      "customerCode": customerCode,
      "firstName": "",
      "lastName": "",
      "mobileNo": "",
      "emailid": "",
      "address": "",
      "aadharNumber": "",
      "panNumber": "",
      "activeStatus": ""
    };

    print('--- GET USER PROFILE REQUEST ---');
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

    print('--- GET USER PROFILE RESPONSE ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      return UserProfileModel.fromJson(responseData);
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }
}