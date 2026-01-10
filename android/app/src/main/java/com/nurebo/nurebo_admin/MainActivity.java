package com.nurebo.nurebo_admin;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
//import com.shounakmulay.telephony.TelephonyPlugin; // Import del plugin


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.nurebo.nurebo_admin/restart";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

//        TelephonyPlugin.registerWith(
//                flutterEngine.getDartExecutor().getBinaryMessenger(),
//                getApplicationContext()
//        );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("restartApp")) {
                                restartApp();
                                result.success(null);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void restartApp() {
        Intent intent = getIntent();
        finish();
        startActivity(intent);
    }
}

