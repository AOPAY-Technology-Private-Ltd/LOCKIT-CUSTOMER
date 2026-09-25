package com.aopay.lockitCustomer

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class PolicyComplianceActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setResult(
            RESULT_OK,
            Intent()
        )

        finish()
    }
}