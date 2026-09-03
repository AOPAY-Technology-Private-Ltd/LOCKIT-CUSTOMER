package com.aopay.lockitCustomer

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val IMEI_CHANNEL = "com.bosoq.device_owner/imei"
    private val SIM_CHANNEL = "com.bosoq.device_owner/sim_info"

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            IMEI_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getImei") {
                val imei = getRealImei()
                if (!imei.isNullOrEmpty()) {
                    result.success(imei)
                } else {
                    result.error("UNAVAILABLE", "IMEI not available or permission denied", null)
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
    }

    private fun getRealImei(): String? {
        try {
            val phoneStatePermission =
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.READ_PHONE_STATE
                )

            if (phoneStatePermission != PackageManager.PERMISSION_GRANTED) {
                return null
            }

            val telephonyManager =
                getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    val imei0 = telephonyManager.getImei(0)
                    if (!imei0.isNullOrEmpty()) return imei0
                } catch (e: Exception) {}

                if (telephonyManager.phoneCount > 1) {
                    try {
                        val imei1 = telephonyManager.getImei(1)
                        if (!imei1.isNullOrEmpty()) return imei1
                    } catch (e: Exception) {}
                }
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