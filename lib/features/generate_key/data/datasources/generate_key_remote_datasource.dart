import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/generate_key_model.dart';

abstract class GenerateKeyRemoteDataSource {
  Future<GenerateKeyModel> generateKeyApi();
}

class GenerateKeyRemoteDataSourceImpl implements GenerateKeyRemoteDataSource {
  GenerateKeyRemoteDataSourceImpl();

  @override
  Future<GenerateKeyModel> generateKeyApi() async {
    const url = 'https://uatapi.aopay.co.in/api/V1/AopayFinance/generatekey';

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final requestBody = {
      "fcmToken": "7852sdsdsdsd"
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

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return GenerateKeyModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to generate key. Status code: ${response.statusCode}');
    }
  }
}