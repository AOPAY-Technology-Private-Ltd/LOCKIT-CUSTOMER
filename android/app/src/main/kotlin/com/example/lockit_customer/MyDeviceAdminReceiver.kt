package com.aopay.lockitCustomer

import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.PersistableBundle
import android.os.UserManager
import android.util.Log
import android.widget.Toast

class MyDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)

        val manager =
            context.getSystemService(Context.DEVICE_POLICY_SERVICE)
                    as DevicePolicyManager

        val admin = ComponentName(context, MyDeviceAdminReceiver::class.java)

        try {
            manager.setUninstallBlocked(
                admin,
                context.packageName,
                true
            )

            Toast.makeText(
                context,
                "Lockit Customer protection enabled",
                Toast.LENGTH_SHORT
            ).show()

        } catch (e: Exception) {
            Toast.makeText(
                context,
                "Failed to enable uninstall protection",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
        super.onProfileProvisioningComplete(context, intent)

        val manager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(context, MyDeviceAdminReceiver::class.java)

        try {
            manager.setProfileName(componentName, "Aopay Customer")
            manager.setUninstallBlocked(componentName, context.packageName, true)
        } catch (e: Exception) {
            Log.e("DeviceAdmin", "Error setting provisioning complete: ${e.message}")
        }

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(launchIntent)
    }

    override fun onTransferOwnershipComplete(context: Context, bundle: PersistableBundle?) {
        super.onTransferOwnershipComplete(context, bundle)

        val manager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(context, MyDeviceAdminReceiver::class.java)

        try {
            manager.setUninstallBlocked(componentName, context.packageName, true)
            Toast.makeText(
                context,
                "Ownership transferred & protection enabled",
                Toast.LENGTH_SHORT
            ).show()
        } catch (e: Exception) {
            Log.e("DeviceAdmin", "Error on transfer ownership complete: ${e.message}")
        }

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(launchIntent)
    }

    override fun onDisabled(
        context: Context,
        intent: Intent
    ) {
        super.onDisabled(context, intent)

        Toast.makeText(
            context,
            "Device Admin Disabled",
            Toast.LENGTH_SHORT
        ).show()
    }
}