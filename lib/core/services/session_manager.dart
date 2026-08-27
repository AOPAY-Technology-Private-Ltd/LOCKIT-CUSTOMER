import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyCustomerCode = 'customer_code';
  static const String _keyMobileNo = 'mobile_no';
  static const String _keyEmailID = 'email_id';
  static const String _keyFirstName = 'first_name';
  static const String _keyLastName = 'last_name';
  static const String _keyFcmToken = 'fcm_token';

  static Future<void> createSession({
    required String customerCode,
    required String mobileNo,
    required String emailID,
    String? firstName,
    String? lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCustomerCode, customerCode);
    await prefs.setString(_keyMobileNo, mobileNo);
    await prefs.setString(_keyEmailID, emailID);
    if (firstName != null) await prefs.setString(_keyFirstName, firstName);
    if (lastName != null) await prefs.setString(_keyLastName, lastName);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<String?> getCustomerCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomerCode);
  }

  static Future<String> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken) ?? '';
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}