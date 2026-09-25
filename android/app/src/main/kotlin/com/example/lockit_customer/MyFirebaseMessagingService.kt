package com.aopay.lockitCustomer

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.d("FCM_NATIVE", "--- 📩 NATIVE BACKGROUND FCM RECEIVED ---")

        try {
            val data = remoteMessage.data
            val payloadStr = data["payload"] ?: data["body"] ?: return
            val jsonObject = JSONObject(payloadStr)

            val rid = jsonObject.optInt("rid", 0)
            val triggeredBy = jsonObject.optString("TriggeredBy", "AFC0328")
            val appActionsArray = jsonObject.optJSONArray("AppActions") ?: jsonObject.optJSONArray("selectedApps")

            val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val adminComponent = ComponentName(this, MyDeviceAdminReceiver::class.java)

            var allAppsExecuted = true

            if (appActionsArray != null && appActionsArray.length() > 0) {
                for (i in 0 until appActionsArray.length()) {
                    val obj = appActionsArray.getJSONObject(i)
                    val pkgName = obj.optString("PackageName").ifEmpty { obj.optString("packageName") }
                    val act = obj.optString("Action").ifEmpty { obj.optString("action") }

                    val cleanPkg = pkgName.lowercase().trim()
                    val actUpper = act.uppercase().trim()

                    if (cleanPkg == "com.aopay.lockitcustomer") continue

                    // ✅ Yahan ACTION ke hisaab se decide hoga ki block karna hai ya unblock
                    // Agar action ENABLE hai, toh restrictions lagani hain (yaani block karna hai)
                    val shouldBlock = (actUpper == "ENABLE")

                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            when (cleanPkg) {
                                "wifi" -> {
                                    devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_WIFI)
                                    Log.d("FCM_NATIVE", "📶 Wifi Restriction -> Blocked: $shouldBlock")
                                }
                                "bluetooth" -> {
                                    devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_BLUETOOTH)
                                    Log.d("FCM_NATIVE", " 블루투스 Bluetooth Restriction -> Blocked: $shouldBlock")
                                }
                                "hotspot", "tethering" -> {
                                    devicePolicyManager.addUserRestriction(adminComponent, android.os.UserManager.DISALLOW_CONFIG_TETHERING)
                                    Log.d("FCM_NATIVE", " hotspot/tethering Restriction -> Blocked: $shouldBlock")
                                }
                                else -> {
                                    if (cleanPkg.contains(".")) {
                                        devicePolicyManager.setPackagesSuspended(adminComponent, arrayOf(cleanPkg), shouldBlock)
                                        devicePolicyManager.setUninstallBlocked(adminComponent, cleanPkg, shouldBlock)
                                        Log.d("FCM_NATIVE", "🔒 Native Background App Action: $cleanPkg -> Blocked: $shouldBlock")
                                    }
                                }
                            }
                        }
                    } catch (e: Exception) {
                        allAppsExecuted = false
                        Log.e("FCM_NATIVE", "Error executing native action for $cleanPkg: ${e.message}")
                    }
                }
            }

            if (rid > 0) {
                updateDeviceActionStatusBackground(rid, if (allAppsExecuted) "Success" else "Failed", triggeredBy)
            } else {
                Log.d("FCM_NATIVE", "⚠️ RID not found in FCM payload.")
            }

        } catch (e: Exception) {
            Log.e("FCM_NATIVE", "❌ Error in Native FCM: ${e.message}", e)
        }
    }

    private fun updateDeviceActionStatusBackground(rid: Int, executionStatus: String, updatedBy: String) {
        Thread {
            try {
                val url = URL("https://uatapi.aopay.co.in/api/notification/UpdateDeviceActionStatus")
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json; utf-8")
                conn.setRequestProperty("Accept", "application/json")
                conn.doOutput = true

                val jsonParam = JSONObject().apply {
                    put("rid", rid)
                    put("executionStatus", executionStatus)
                    put("failureReason", if (executionStatus == "Success") "" else "Error executing some apps")
                    put("updatedBy", updatedBy)
                    put("devicePin", "")
                    put("iccid", "")
                    put("subscriptionId", 0)
                    put("carrierName", "")
                    put("mcc", "")
                    put("mnc", "")
                    put("slotIndex", 0)
                }

                val os = OutputStreamWriter(conn.outputStream)
                os.write(jsonParam.toString())
                os.flush()
                os.close()

                conn.responseCode
            } catch (e: Exception) {}
        }.start()
    }
}