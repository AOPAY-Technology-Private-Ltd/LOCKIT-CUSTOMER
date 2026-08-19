import 'package:http/http.dart' as http;

class ApiClient {
  static Future<http.Response> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return await http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> get(
      Uri url, {
        Map<String, String>? headers,
      }) async {
    return await http.get(url, headers: headers);
  }
}