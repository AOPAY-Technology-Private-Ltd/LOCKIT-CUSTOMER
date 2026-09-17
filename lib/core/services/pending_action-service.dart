// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:lockit_customer/core/services/session_manager.dart';
// import '../../../../core/constants/apiconstants/api_constants.dart';
// import '../../../../core/utils/device_action_channel.dart';
// import '../../features/auth/data/datasource/auth_remote_datasource.dart';
//
// class PendingActionService {
//   static Future<void> checkPendingDeviceActions() async {
//     try {
//       final customerCode =
//           await SessionManager.getCustomerCode() ?? '';
//       final clientCode =
//           await SessionManager.getClientCode() ?? '';
//
//       if (customerCode.isEmpty || clientCode.isEmpty) {
//         print('❌ CustomerCode or ClientCode is empty');
//         return;
//       }
//
//       final url =
//       Uri.parse(ApiConstants.PendingActionService);
//
//       final requestBody = {
//         "customerCode": customerCode,
//         "clientcode": clientCode,
//       };
//
//       print('--- 🚀 CHECKING PENDING DEVICE ACTIONS ---');
//       print('URL: $url');
//       print('Request Body: ${jsonEncode(requestBody)}');
//
//       final response = await http.post(
//         url,
//         headers: {
//           'accept': '*/*',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(requestBody),
//       );
//
//       print('--- 📥 PENDING DEVICE ACTIONS RESPONSE ---');
//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode != 200 &&
//           response.statusCode != 201) {
//         print('❌ Pending action API failed');
//         return;
//       }
//
//       final decoded = jsonDecode(response.body);
//
//       // =========================================================
//       // TOP LEVEL STATUS
//       // =========================================================
//
//       final bool apiStatus =
//           decoded is Map && decoded['status'] == true;
//
//       print('==============================');
//       print('TOP LEVEL API STATUS: $apiStatus');
//       print('==============================');
//
//       if (!apiStatus) {
//         print('❌ Pending API status is false');
//         return;
//       }
//
//       final List dataList =
//       decoded['data'] is List ? decoded['data'] : [];
//
//       print(
//         '--- 📊 TOTAL PENDING ACTIONS: ${dataList.length} ---',
//       );
//
//       for (final actionItem in dataList) {
//         final int rid =
//             int.tryParse(
//               actionItem['rid']?.toString() ?? '0',
//             ) ??
//                 0;
//
//         final String notificationCode =
//             actionItem['notificationCode']?.toString() ?? '';
//
//         final bool actionStatus =
//             actionItem['actionStatus'] == true;
//
//         final List selectedApps =
//         actionItem['selectedApps'] is List
//             ? actionItem['selectedApps']
//             : [];
//
//         print('');
//         print('======================================');
//         print('RID              : $rid');
//         print('NotificationCode : $notificationCode');
//         print('Top Status       : $apiStatus');
//         print('Action Status    : $actionStatus');
//         print('Selected Apps    : ${selectedApps.length}');
//         print('======================================');
//
//         bool allAppsExecuted = true;
//
//         // =========================================================
//         // EXECUTE DEVICE ACTION
//         // =========================================================
//
//         for (final app in selectedApps) {
//           final String packageName =
//               app['packageName']?.toString() ?? '';
//
//           final String actionType =
//               app['action']?.toString() ?? '';
//
//           print('');
//           print('👉 ABOUT TO EXECUTE ACTION');
//           print('Package : $packageName');
//           print('Action  : $actionType');
//
//           try {
//             print('⏳ Calling DeviceActionChannel...');
//
//             await DeviceActionChannel.performAction(
//               notificationCode: notificationCode,
//               packageName: packageName,
//               action: actionType,
//             ).timeout(
//               const Duration(seconds: 10),
//             );
//
//             print(
//               '✅ DeviceActionChannel completed: $packageName',
//             );
//           } catch (e) {
//             allAppsExecuted = false;
//
//             print(
//               '❌ DeviceActionChannel FAILED: $packageName',
//             );
//             print('Error: $e');
//           }
//         }
//
//         // =========================================================
//         // UPDATE SERVER
//         // =========================================================
//
//         print('');
//         print('======================================');
//         print('🚨 REACHED UPDATE API SECTION');
//         print('RID              : $rid');
//         print('Top API Status   : $apiStatus');
//         print('All Apps Executed: $allAppsExecuted');
//         print('======================================');
//
//         if (apiStatus && rid > 0) {
//           print(
//             '--- 🚀 INITIATING SERVER UPDATE FOR RID $rid ---',
//           );
//
//           final bool isUpdated =
//           await UpdateDeviceActionService
//               .updateDeviceActionStatus(
//             rid: rid,
//
//             // Agar saare actions successful hain
//             // to Success otherwise Failed
//             executionStatus:
//             allAppsExecuted ? "Success" : "Failed",
//
//             failureReason:
//             allAppsExecuted
//                 ? ""
//                 : "Error executing some apps",
//
//             updatedBy: customerCode,
//             devicePin: "",
//           );
//
//           print(
//             '--- 📥 SERVER UPDATE RESULT FOR RID $rid: $isUpdated ---',
//           );
//         } else {
//           print(
//             '❌ UPDATE API NOT CALLED: '
//                 'apiStatus=$apiStatus, rid=$rid',
//           );
//         }
//       }
//     } catch (e, stackTrace) {
//       print('--- ❌ PENDING DEVICE ACTIONS ERROR ---');
//       print('Error: $e');
//       print('StackTrace: $stackTrace');
//     }
//   }
// }
