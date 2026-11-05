package com.nurebo.nurebo_admin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class StartActivityOnBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        Log.d("BootReceiver", "onReceive: ${intent?.action}")

        if (intent?.action == Intent.ACTION_BOOT_COMPLETED ||
            intent?.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent?.action == Intent.ACTION_LOCKED_BOOT_COMPLETED) {

            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(launchIntent)
        }
    }
}