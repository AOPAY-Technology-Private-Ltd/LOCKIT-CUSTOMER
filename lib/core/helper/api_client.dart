import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class ApiClient {
  static String? _cachedAppVersion;

  static Future<String> _getAppVersion() async {
    if (_cachedAppVersion != null) return _cachedAppVersion!;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _cachedAppVersion = packageInfo.version;
    } catch (_) {
      _cachedAppVersion = '1.0.0';
    }
    return _cachedAppVersion!;
  }

  static Future<Map<String, String>> _getHeaders(Map<String, String>? userHeaders) async {
    final version = await _getAppVersion();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'accept': '*/*',
      'x-app-version': version,
    };

    if (userHeaders != null) {
      headers.addAll(userHeaders);
    }
    return headers;
  }

  static Future<http.Response> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final finalHeaders = await _getHeaders(headers);
    return await http.post(url, headers: finalHeaders, body: body);
  }

  static Future<http.Response> get(
      Uri url, {
        Map<String, String>? headers,
      }) async {
    final finalHeaders = await _getHeaders(headers);
    return await http.get(url, headers: finalHeaders);
  }
}