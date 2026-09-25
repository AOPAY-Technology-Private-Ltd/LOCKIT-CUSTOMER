import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/apiconstants/api_constants.dart';
import '../../../../core/helper/api_client.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/network/network_service.dart';

class DeviceLockScreen extends StatefulWidget {
  const DeviceLockScreen({Key? key}) : super(key: key);

  @override
  State<DeviceLockScreen> createState() => _DeviceLockScreenState();
}

class _DeviceLockScreenState extends State<DeviceLockScreen> {
  static const platform = MethodChannel('com.aopay.lockitCustomer/lock');

  bool isLoading = true;
  String retailerName = "Loading...";
  String retailerPhone = "Loading...";
  String retailerEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _lockDeviceTask();
    _fetchRetailerProfile(); // API se data fetch karne ke liye
  }

  Future<void> _lockDeviceTask() async {
    try {
      await platform.invokeMethod('lockDevice');
      print("🔒 Native Lock Task Started Successfully");
    } on PlatformException catch (e) {
      print("❌ Failed to start lock task: '${e.message}'");
    }
  }

  Future<void> _unlockDeviceTask() async {
    try {
      await platform.invokeMethod('unlockDevice');
      print("🔓 Native Lock Task Stopped Successfully");
    } on PlatformException catch (e) {
      print("❌ Failed to stop lock task: '${e.message}'");
    }
  }

  // API se profile data fetch karne ka method
  Future<void> _fetchRetailerProfile() async {
    try {
      final bool hasConnection = await NetworkService.hasInternet();
      if (!hasConnection) {
        setState(() {
          retailerName = "Support Team";
          retailerPhone = "N/A";
          retailerEmail = "N/A";
          isLoading = false;
        });
        return;
      }

      final String? customerCode = await SessionManager.getCustomerCode();
      if (customerCode == null || customerCode.isEmpty) {
        setState(() => isLoading = false);
        return;
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
        "aadharNumber": "[Redacted]",
        "panNumber": "",
        "activeStatus": ""
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
        final data = jsonDecode(response.body);

        // Response ke anusaar fields set karein (jaise firstName, mobileNo, emailid)
        setState(() {
          String fName = data['firstName'] ?? '';
          String lName = data['lastName'] ?? '';
          String fullName = "$fName $lName".trim();

          retailerName = fullName.isNotEmpty ? fullName : "Authorized Retailer";
          retailerPhone = data['mobileNo'] ?? data['phone'] ?? "N/A";
          retailerEmail = data['emailid'] ?? data['email'] ?? "N/A";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching profile for lock screen: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _unlockDeviceTask();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Back button completely disabled
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6EA8FE), Color(0xFF1338BE)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 80,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "EMI DUE",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "This device is locked due to a pending payment.\nTo unlock, please contact your retailer $retailerName at $retailerPhone or email at $retailerEmail",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}