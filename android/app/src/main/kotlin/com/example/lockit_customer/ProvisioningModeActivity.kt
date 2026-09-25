package com.aopay.lockitCustomer

import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.Intent
import android.os.Bundle

class ProvisioningModeActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val allowedModes =
            intent.getIntegerArrayListExtra(
                DevicePolicyManager.EXTRA_PROVISIONING_ALLOWED_PROVISIONING_MODES
            )

        val fullyManagedMode =
            DevicePolicyManager.PROVISIONING_MODE_FULLY_MANAGED_DEVICE

        if (allowedModes != null &&
            !allowedModes.contains(fullyManagedMode)
        ) {
            setResult(RESULT_CANCELED)
            finish()
            return
        }

        val resultIntent = Intent()

        resultIntent.putExtra(
            DevicePolicyManager.EXTRA_PROVISIONING_MODE,
            fullyManagedMode
        )

        setResult(
            RESULT_OK,
            resultIntent
        )

        finish()
    }
}