package com.aopay.lockitCustomer

import android.content.Context
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DeviceActionPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.bosoq.device_owner/actions")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "performAction") {
            val notificationCode = call.argument<String>("notificationCode")
            val singlePackageName = call.argument<String>("packageName")
            val singleAction = call.argument<String>("action")
            val rawAppActions = call.argument<List<Any>>("appActions")

            try {
                val devicePolicyManager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
                val adminComponent = android.content.ComponentName(context, MyDeviceAdminReceiver::class.java)

                fun executeAction(pkgName: String?, act: String?) {
                    val cleanPackageName = pkgName?.lowercase()?.trim() ?: ""
                    val actionUpper = act?.uppercase() ?: ""

                    if (pkgName == "com.aopay.lockitCustomer") return

                    val shouldBlock = (actionUpper == "ENABLE")

                    when (cleanPackageName) {
                        "hotspot", "tethering" -> {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                if (shouldBlock) {
                                    devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_TETHERING)
                                } else {
                                    devicePolicyManager.clearUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_TETHERING)
                                }
                            }
                        }
                        else -> {
                            if (!pkgName.isNullOrEmpty() && pkgName.contains(".")) {
                                try {
                                    if (shouldBlock) {
                                        try {
                                            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
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
                                    } else {
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                            devicePolicyManager.setPackagesSuspended(adminComponent, arrayOf(pkgName), false)
                                        }
                                        try {
                                            devicePolicyManager.setUninstallBlocked(adminComponent, pkgName, false)
                                        } catch (e: Exception) {}
                                    }
                                } catch (e: Exception) {
                                    Log.e("DEVICE_PLUGIN", "Error: ${e.message}")
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
                result.error("ACTION_FAILED", e.message, null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}