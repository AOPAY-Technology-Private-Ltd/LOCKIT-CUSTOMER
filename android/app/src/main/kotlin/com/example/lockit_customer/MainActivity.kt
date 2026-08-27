package com.aopay.lockitCustomer

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.bosoq.device_owner/imei"

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "getImei") {

                Log.d("REAL_IMEI", "================================")
                Log.d("REAL_IMEI", "getImei() called from Flutter")
                Log.d("REAL_IMEI", "Android SDK: ${Build.VERSION.SDK_INT}")
                Log.d("REAL_IMEI", "Device: ${Build.MANUFACTURER} ${Build.MODEL}")
                Log.d("REAL_IMEI", "================================")

                val imei = getRealImei()

                if (!imei.isNullOrEmpty()) {

                    Log.d(
                        "REAL_IMEI",
                        "SUCCESS - REAL IMEI: $imei"
                    )

                    result.success(imei)

                } else {

                    Log.e(
                        "REAL_IMEI",
                        "FAILED - REAL IMEI NOT AVAILABLE"
                    )

                    result.error(
                        "UNAVAILABLE",
                        "IMEI not available or permission denied",
                        null
                    )
                }

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

                Log.e(
                    "REAL_IMEI",
                    "READ_PHONE_STATE permission NOT GRANTED"
                )

                return null
            }

            Log.d(
                "REAL_IMEI",
                "READ_PHONE_STATE permission GRANTED"
            )


            val telephonyManager =
                getSystemService(
                    Context.TELEPHONY_SERVICE
                ) as TelephonyManager

            Log.d(
                "REAL_IMEI",
                "Phone count: ${telephonyManager.phoneCount}"
            )


            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {



                try {

                    val imei0 =
                        telephonyManager.getImei(0)

                    Log.d(
                        "REAL_IMEI",
                        "IMEI slot 0: $imei0"
                    )

                    if (!imei0.isNullOrEmpty()) {
                        return imei0
                    }

                } catch (e: SecurityException) {

                    Log.e(
                        "REAL_IMEI",
                        "SecurityException slot 0: ${e.message}",
                        e
                    )

                } catch (e: Exception) {

                    Log.e(
                        "REAL_IMEI",
                        "Exception slot 0: ${e.message}",
                        e
                    )
                }



                if (telephonyManager.phoneCount > 1) {

                    try {

                        val imei1 =
                            telephonyManager.getImei(1)

                        Log.d(
                            "REAL_IMEI",
                            "IMEI slot 1: $imei1"
                        )

                        if (!imei1.isNullOrEmpty()) {
                            return imei1
                        }

                    } catch (e: SecurityException) {

                        Log.e(
                            "REAL_IMEI",
                            "SecurityException slot 1: ${e.message}",
                            e
                        )

                    } catch (e: Exception) {

                        Log.e(
                            "REAL_IMEI",
                            "Exception slot 1: ${e.message}",
                            e
                        )
                    }
                }

                Log.e(
                    "REAL_IMEI",
                    "No IMEI returned from any SIM slot"
                )

                return null
            }



            @Suppress("DEPRECATION")
            val oldImei =
                telephonyManager.deviceId

            Log.d(
                "REAL_IMEI",
                "Legacy deviceId: $oldImei"
            )

            return oldImei

        } catch (e: SecurityException) {

            Log.e(
                "REAL_IMEI",
                "SECURITY EXCEPTION: ${e.message}",
                e
            )

            return null

        } catch (e: Exception) {

            Log.e(
                "REAL_IMEI",
                "IMEI ERROR: ${e.message}",
                e
            )

            return null
        }
    }
}