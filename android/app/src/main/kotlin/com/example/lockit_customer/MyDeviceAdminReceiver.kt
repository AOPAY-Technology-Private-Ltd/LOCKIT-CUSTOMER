package com.aopay.lockitCustomer

import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.UserManager
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

    override fun onProfileProvisioningComplete(
        context: Context,
        intent: Intent
    ) {
        super.onProfileProvisioningComplete(context, intent)

        val manager = getManager(context)
        val componentName = getWho(context)

        manager.setProfileName(
            componentName,
            "Aopay Customer"
        )

        try {
            manager.setUninstallBlocked(
                componentName,
                context.packageName,
                true
            )
        } catch (e: Exception) {
        }

        val launchIntent =
            context.packageManager
                .getLaunchIntentForPackage(context.packageName)

        launchIntent?.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK
        )

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