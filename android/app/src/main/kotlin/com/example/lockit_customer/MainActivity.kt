package com.aopay.lockitCustomer

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
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
    private val LOCK_CHANNEL = "com.aopay.lockitCustomer/lock"
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
            if (call.method == "performAction") {
                val singlePackageName = call.argument<String>("packageName")
                val singleAction = call.argument<String>("action")
                val rawAppActions = call.argument<List<Any>>("appActions")

                try {
                    val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
                    val adminComponent = android.content.ComponentName(this, MyDeviceAdminReceiver::class.java)

                    fun getDefaultDialerPackage(): String? {
                        try {
                            val intent = Intent(Intent.ACTION_DIAL).apply {
                                data = Uri.parse("tel:123")
                            }
                            val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                            val packageName = resolveInfo?.activityInfo?.packageName
                            if (!packageName.isNullOrEmpty()) {
                                Log.d("DEVICE_ACTION", "📱 Detected Default Dialer: $packageName")
                                return packageName
                            }
                        } catch (e: Exception) {
                            Log.e("DEVICE_ACTION", "Error detecting default dialer: ${e.message}")
                        }

                        // Fallback common packages agar intent se na mile
                        val fallbacks = arrayOf(
                            "com.google.android.dialer",
                            "com.samsung.android.dialer",
                            "com.android.dialer",
                            "com.oneplus.dialer",
                            "com.vivo.dialer",
                            "com.oppo.dialer"
                        )
                        for (pkg in fallbacks) {
                            try {
                                packageManager.getPackageInfo(pkg, 0)
                                Log.d("DEVICE_ACTION", "📱 Found Fallback Dialer: $pkg")
                                return pkg
                            } catch (e: Exception) {}
                        }
                        return null
                    }

                    fun executeAction(pkgName: String?, act: String?) {
                        val cleanPackageName = pkgName?.lowercase()?.trim() ?: ""
                        val actionUpper = act?.uppercase()?.trim() ?: ""

                        if (cleanPackageName == "com.aopay.lockitcustomer") return

                        val shouldBlock = (actionUpper == "ENABLE")

                        when (cleanPackageName) {
                            "wifi", "wi-fi" -> {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    try {
                                        if (shouldBlock) {
                                            devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_WIFI)
                                            Log.d("DEVICE_ACTION", "📶 Wifi Restricted/Blocked")
                                        } else {
                                            devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_WIFI)
                                            Log.d("DEVICE_ACTION", "📶 Wifi Restored/Unblocked")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("DEVICE_ACTION", "Wifi restriction error: ${e.message}")
                                    }
                                }
                            }
                            "bluetooth" -> {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    try {
                                        if (shouldBlock) {
                                            devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_BLUETOOTH)
                                            Log.d("DEVICE_ACTION", "Bluetooth Restricted/Blocked")
                                        } else {
                                            devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_BLUETOOTH)
                                            Log.d("DEVICE_ACTION", "Bluetooth Restored/Unblocked")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("DEVICE_ACTION", "Bluetooth restriction error: ${e.message}")
                                    }
                                }
                            }
                            "hotspot", "tethering" -> {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    try {
                                        if (shouldBlock) {
                                            devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_TETHERING)
                                            Log.d("DEVICE_ACTION", "Hotspot/Tethering Restricted/Blocked")
                                        } else {
                                            devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_TETHERING)
                                            Log.d("DEVICE_ACTION", "Hotspot/Tethering Restored/Unblocked")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("DEVICE_ACTION", "Tethering restriction error: ${e.message}")
                                    }
                                }
                            }
                            "airplane_mode", "airplanemode", "air_plane_mode" -> {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                                    try {
                                        if (shouldBlock) {
                                            devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_AIRPLANE_MODE)
                                            Log.d("DEVICE_ACTION", "✈️ Airplane Mode Restricted/Blocked Successfully")
                                        } else {
                                            devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_AIRPLANE_MODE)
                                            Log.d("DEVICE_ACTION", "✈️ Airplane Mode Restored/Unblocked Successfully")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("DEVICE_ACTION", "Airplane Mode restriction error: ${e.message}")
                                    }
                                }
                            }
                            "kiosk_mode", "kiosk" -> {
                                try {
                                    if (actionUpper == "ENABLE") {
                                        startLockTask()
                                        Log.d("DEVICE_ACTION", "🔒 Kiosk Mode (Lock Task) Enabled Successfully")
                                    } else if (actionUpper == "DISABLE") {
                                        stopLockTask()
                                        Log.d("DEVICE_ACTION", "🔓 Kiosk Mode (Lock Task) Disabled Successfully")
                                    }
                                } catch (e: Exception) {
                                    Log.e("DEVICE_ACTION", "Kiosk Mode action error: ${e.message}")
                                }
                            }

                            "reboot", "restart" -> {
                                try {
                                    if (actionUpper == "ENABLE" || actionUpper == "REBOOT") {
                                        Log.d("DEVICE_ACTION", "🔄 Attempting hard reboot via PowerManager...")

                                        try {
                                            stopLockTask()
                                        } catch (e: Exception) {}

                                        // Method A: Standard DevicePolicyManager
                                        try {
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                                devicePolicyManager.reboot(adminComponent)
                                            }
                                        } catch (e: Exception) {
                                            Log.e("DEVICE_ACTION", "DPM reboot failed: ${e.message}")
                                        }

                                        // Method B: PowerManager re-boot service call
                                        try {
                                            val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
                                            // 'reboot' argument mein null ya "recovery" / "safemode" de sakte hain
                                            powerManager.reboot(null)
                                        } catch (e: Exception) {
                                            Log.e("DEVICE_ACTION", "PowerManager reboot failed: ${e.message}")
                                        }
                                    }
                                } catch (e: Exception) {
                                    Log.e("DEVICE_ACTION", "❌ Reboot error: ${e.message}", e)
                                }
                            }
                            "disable_camera", "camera" -> {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    try {
                                        if (shouldBlock) {
                                            devicePolicyManager.addUserRestriction(adminComponent, "no_camera")
                                            Log.d("DEVICE_ACTION", "📷 Camera Restricted/Blocked Successfully")
                                        } else {
                                            devicePolicyManager.clearUserRestriction(adminComponent, "no_camera")
                                            Log.d("DEVICE_ACTION", "📷 Camera Restored/Unblocked Successfully")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("DEVICE_ACTION", "Camera restriction error: ${e.message}")
                                    }
                                }
                            }
                            "disable_call", "call" -> {
                                val dialerPkg = getDefaultDialerPackage() ?: "com.android.dialer"
                                Log.d("DEVICE_ACTION", "🔥 TARGET DIALER PACKAGE: $dialerPkg")

                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    try {
                                        if (shouldBlock) {
                                            devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_OUTGOING_CALLS)

                                            try {
                                                val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
                                                activityManager.killBackgroundProcesses(dialerPkg)
                                            } catch (e: Exception) {}

                                            devicePolicyManager.setPackagesSuspended(adminComponent, arrayOf(dialerPkg), true)

                                            Log.d("DEVICE_ACTION", "📞 Successfully SUSPENDED Dialer: $dialerPkg")
                                        } else {
                                            devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_OUTGOING_CALLS)

                                            devicePolicyManager.setPackagesSuspended(adminComponent, arrayOf(dialerPkg), false)

                                            Log.d("DEVICE_ACTION", "📞 Successfully RESTORED Dialer: $dialerPkg")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("DEVICE_ACTION", "Dialer action error: ${e.message}")
                                    }
                                }
                            }
                            else -> {
                                if (!pkgName.isNullOrEmpty() && pkgName.contains(".")) {
                                    try {
                                        if (shouldBlock) {
                                            try {
                                                val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
                                                activityManager.killBackgroundProcesses(pkgName)
                                            } catch (e: Exception) {}

                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                                try {
                                                    devicePolicyManager.setPackagesSuspended(adminComponent, arrayOf(pkgName), true)
                                                } catch (e: Exception) {}
                                            }

                                            try {
                                                devicePolicyManager.setUninstallBlocked(adminComponent, pkgName, true)
                                            } catch (e: Exception) {}

                                            Log.d("DEVICE_ACTION", "🔒 Successfully SUSPENDED (Locked): $pkgName")
                                        } else {
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                                try {
                                                    devicePolicyManager.setPackagesSuspended(adminComponent, arrayOf(pkgName), false)
                                                } catch (e: Exception) {}
                                            }

                                            try {
                                                devicePolicyManager.setUninstallBlocked(adminComponent, pkgName, false)
                                            } catch (e: Exception) {}

                                            Log.d("DEVICE_ACTION", "🔓 Successfully RESTORED (Unlocked): $pkgName")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("DEVICE_ACTION", "Error executing action for $pkgName: ${e.message}")
                                    }
                                }
                            }
                        }
                    }

                    if (!rawAppActions.isNullOrEmpty()) {
                        for (item in rawAppActions) {
                            if (item is Map<*, *>) {
                                val pName = (item["PackageName"] ?: item["packageName"]) as? String
                                val act = (item["Action"] ?: item["action"]) as? String
                                executeAction(pName, act)
                            }
                        }
                    } else if (!singlePackageName.isNullOrEmpty()) {
                        executeAction(singlePackageName, singleAction)
                    }

                    result.success(true)
                } catch (e: Exception) {
                    Log.e("DEVICE_ACTION", "❌ CRITICAL ERROR: ${e.message}", e)
                    result.error("ACTION_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // 4. Kiosk / Lock Task Mode Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LOCK_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "lockDevice" -> {
                    try {
                        startLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("LOCK_FAILED", e.message, null)
                    }
                }
                "unlockDevice" -> {
                    try {
                        stopLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNLOCK_FAILED", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
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
            val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    val imei0 = telephonyManager.getImei(0)
                    if (!imei0.isNullOrEmpty()) return imei0
                } catch (e: Exception) {}
                try {
                    if (telephonyManager.phoneCount > 1) {
                        val imei1 = telephonyManager.getImei(1)
                        if (!imei1.isNullOrEmpty()) return imei1
                    }
                } catch (e: Exception) {}
                @Suppress("DEPRECATION")
                val deviceId = telephonyManager.deviceId
                if (!deviceId.isNullOrEmpty()) return deviceId
                return null
            }
            @Suppress("DEPRECATION")
            return telephonyManager.deviceId
        } catch (e: Exception) {
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
                val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
                val subscriptionInfoList = subscriptionManager?.activeSubscriptionInfoList
                if (!subscriptionInfoList.isNullOrEmpty()) {
                    val info = subscriptionInfoList[0]
                    slotIndex = info.simSlotIndex
                    subscriptionId = info.subscriptionId
                    mcc = info.mccString ?: ""
                    mnc = info.mncString ?: ""
                    val telephonyManager = (getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager)
                        .createForSubscriptionId(info.subscriptionId)
                    carrierName = telephonyManager.simOperatorName.ifEmpty { info.carrierName?.toString() ?: "" }
                }
            } catch (e: Exception) {}
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