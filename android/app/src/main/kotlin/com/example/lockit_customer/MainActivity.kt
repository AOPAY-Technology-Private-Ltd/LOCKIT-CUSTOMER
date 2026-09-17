package com.aopay.lockitCustomer

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val IMEI_CHANNEL = "com.bosoq.device_owner/imei"
    private val SIM_CHANNEL = "com.bosoq.device_owner/sim_info"
    private val ACTION_CHANNEL = "com.bosoq.device_owner/actions"
    private val PERMISSION_REQUEST_CODE = 100

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            IMEI_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getImei") {
                val permission = ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.READ_PHONE_STATE
                )

                if (permission != PackageManager.PERMISSION_GRANTED) {
                    pendingResult = result
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.READ_PHONE_STATE, Manifest.permission.READ_PHONE_NUMBERS),
                        PERMISSION_REQUEST_CODE
                    )
                } else {
                    val imei = getRealImei()
                    if (!imei.isNullOrEmpty()) {
                        result.success(imei)
                    } else {
                        result.error("UNAVAILABLE", "IMEI not available", null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SIM_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getSimInfo") {
                val simData = getSimDetails()
                result.success(simData)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ACTION_CHANNEL
        ).setMethodCallHandler { call, result ->
            val notificationCode = call.argument<String>("notificationCode")
            val packageName = call.argument<String>("packageName")
            val action = call.argument<String>("action")

            Log.d("DEBUG_ACTION", "--------------------------------------------------")
            Log.d("DEBUG_ACTION", "-> Method called from Flutter!")
            Log.d("DEBUG_ACTION", "-> NotificationCode: $notificationCode")
            Log.d("DEBUG_ACTION", "-> PackageName: $packageName")
            Log.d("DEBUG_ACTION", "-> Action: $action")

            try {
                val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
                val adminComponent = android.content.ComponentName(this, MyDeviceAdminReceiver::class.java)

                val isAdminActive = devicePolicyManager.isAdminActive(adminComponent)
                Log.d("DEBUG_ACTION", "-> Is Admin Active: $isAdminActive")

                val isEnable = (action?.uppercase() == "ENABLE")

                when (packageName) {
                    "Hotspot" -> {
                        Log.d("DEBUG_ACTION", "-> Processing Hotspot restriction")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            if (isEnable) {
                                devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_TETHERING)
                            } else {
                                devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_TETHERING)
                            }
                        }
                    }
                    "USB" -> {
                        Log.d("DEBUG_ACTION", "-> Processing USB restriction")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (isEnable) {
                                devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_USB_FILE_TRANSFER)
                            } else {
                                devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_USB_FILE_TRANSFER)
                            }
                        }
                    }
                    "DISABLE_CALL" -> {
                        Log.d("DEBUG_ACTION", "-> Processing Call Disable action")
                    }
                    else -> {
                        Log.d("DEBUG_ACTION", "-> Processing App Package: $packageName with Code: $notificationCode")
                        if (!packageName.isNullOrEmpty() && packageName.contains(".")) {
                            try {
                                if (notificationCode == "APP_HIDE") {
                                    devicePolicyManager.setApplicationHidden(
                                        adminComponent,
                                        packageName,
                                        isEnable
                                    )
                                    Log.d("DEBUG_ACTION", "✅ SUCCESS: App hidden state set to $isEnable for $packageName")
                                } else {
                                    if (isEnable) {
                                        try {
                                            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
                                            activityManager.killBackgroundProcesses(packageName)
                                        } catch (e: Exception) {}

                                        try {
                                            devicePolicyManager.setUninstallBlocked(adminComponent, packageName, true)
                                            Log.d("DEBUG_ACTION", "✅ SUCCESS: App uninstall blocked & background killed for $packageName (Icon remains visible)")
                                        } catch (e: Exception) {
                                            Log.e("DEBUG_ACTION", "❌ Error blocking uninstall: ${e.message}")
                                        }
                                    } else {
                                        try {
                                            devicePolicyManager.setUninstallBlocked(adminComponent, packageName, false)
                                            Log.d("DEBUG_ACTION", "✅ SUCCESS: App uninstall unblocked for $packageName")
                                        } catch (e: Exception) {}
                                    }
                                }
                            } catch (secEx: SecurityException) {
                                Log.e("DEBUG_ACTION", "❌ SECURITY EXCEPTION: ${secEx.message}")
                            } catch (ex: Exception) {
                                Log.e("DEBUG_ACTION", "❌ EXCEPTION: ${ex.message}")
                            }
                        } else {
                            Log.w("DEBUG_ACTION", "⚠️ Invalid or empty package name: $packageName")
                        }
                    }
                }

                result.success(true)
            } catch (e: Exception) {
                Log.e("DEBUG_ACTION", "❌ CRITICAL ERROR in performAction: ${e.message}", e)
                result.error("ACTION_FAILED", e.message, null)
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                val imei = getRealImei()
                if (!imei.isNullOrEmpty()) {
                    pendingResult?.success(imei)
                } else {
                    pendingResult?.error("UNAVAILABLE", "IMEI not available after permission granted", null)
                }
            } else {
                pendingResult?.error("PERMISSION_DENIED", "READ_PHONE_STATE permission denied", null)
            }
            pendingResult = null
        }
    }

    private fun getRealImei(): String? {
        try {
            val telephonyManager =
                getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    val imei0 = telephonyManager.getImei(0)
                    if (!imei0.isNullOrEmpty()) return imei0
                } catch (e: Exception) {
                    Log.e("IMEI", "Error reading IMEI 0: ${e.message}")
                }

                try {
                    if (telephonyManager.phoneCount > 1) {
                        val imei1 = telephonyManager.getImei(1)
                        if (!imei1.isNullOrEmpty()) return imei1
                    }
                } catch (e: Exception) {
                    Log.e("IMEI", "Error reading IMEI 1: ${e.message}")
                }

                @Suppress("DEPRECATION")
                val deviceId = telephonyManager.deviceId
                if (!deviceId.isNullOrEmpty()) return deviceId

                return null
            }

            @Suppress("DEPRECATION")
            return telephonyManager.deviceId
        } catch (e: Exception) {
            Log.e("IMEI", "General exception fetching IMEI: ${e.message}")
            return null
        }
    }

    private fun getSimDetails(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        try {
            val phoneStatePermission = ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_PHONE_STATE
            )

            if (phoneStatePermission != PackageManager.PERMISSION_GRANTED) {
                map["carrierName"] = ""
                map["mcc"] = ""
                map["mnc"] = ""
                map["slotIndex"] = 0
                map["subscriptionId"] = 0
                map["serialNumber"] = "unknown"
                return map
            }

            var carrierName = ""
            var mcc = ""
            var mnc = ""
            var slotIndex = 0
            var subscriptionId = 0

            try {
                val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
                val subscriptionInfoList = subscriptionManager?.activeSubscriptionInfoList

                if (!subscriptionInfoList.isNullOrEmpty()) {
                    val info = subscriptionInfoList[0]
                    slotIndex = info.simSlotIndex
                    subscriptionId = info.subscriptionId
                    mcc = info.mccString ?: ""
                    mnc = info.mncString ?: ""

                    val telephonyManager = (context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager)
                        .createForSubscriptionId(info.subscriptionId)

                    carrierName = telephonyManager.simOperatorName.ifEmpty { info.carrierName?.toString() ?: "" }
                }
            } catch (e: Exception) {
                Log.e("SIM_INFO", "SubscriptionManager error: ${e.message}")
            }

            if (carrierName.isEmpty() || mcc.isEmpty()) {
                val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                if (carrierName.isEmpty()) {
                    carrierName = tm.simOperatorName ?: tm.networkOperatorName ?: ""
                }
                val simOperator = tm.simOperator.ifEmpty { tm.networkOperator ?: "" }
                if (simOperator.length >= 5) {
                    if (mcc.isEmpty()) mcc = simOperator.substring(0, 3)
                    if (mnc.isEmpty()) mnc = simOperator.substring(3)
                }
            }

            map["carrierName"] = carrierName
            map["mcc"] = mcc
            map["mnc"] = mnc
            map["slotIndex"] = slotIndex
            map["subscriptionId"] = subscriptionId
            map["serialNumber"] = "unknown"

        } catch (e: Exception) {
            Log.e("SIM_INFO", "Error: ${e.message}")
            map["carrierName"] = ""
            map["mcc"] = ""
            map["mnc"] = ""
            map["slotIndex"] = 0
            map["subscriptionId"] = 0
            map["serialNumber"] = "unknown"
        }
        return map
    }
}