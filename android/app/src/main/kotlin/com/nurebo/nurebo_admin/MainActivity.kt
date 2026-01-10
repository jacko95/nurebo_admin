package com.nurebo.nurebo_admin.com.nurebo.nurebo_admin // Sostituisci con il tuo package name

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
//import com.shounakmulay.telephony.TelephonyPlugin



class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Registra il plugin Telephony
//        TelephonyPlugin.registerWith(
//            flutterEngine.dartExecutor.binaryMessenger,
//            applicationContext
//        )
    }
}