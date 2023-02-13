// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package baotin.com.store;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String SCANQRCODE_CHANNEL = "baotin.pda.qrcode/scan";
    private static final String GETQRCODE_CHANNEL = "baotin.pda.qrcode/get";

    private static String ACTION_SCANNER_RESULT = "nlscan.action.SCANNER_RESULT";
    private static String ACTION_SCANNER_STOP = "nlscan.action.STOP_SCAN";
    private static String ACTION_SCANNER_TRIG = "nlscan.action.SCANNER_TRIG";
    private static String ACTION_BAR_SCANCFG = "ACTION_BAR_SCANCFG";
    private static String ACTION_BAR_SCANCFG_EXTRA = "EXTRA_SCAN_MODE";
    private static String SCAN_BARCODE1 = "SCAN_BARCODE1";
    private static String SCAN_BARCODE2 = "SCAN_BARCODE2";
    private static String SCAN_STATE = "SCAN_STATE";
    private static String SCAN_STATE_OK = "ok";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        new EventChannel(flutterEngine.getDartExecutor(), GETQRCODE_CHANNEL).setStreamHandler(
                new StreamHandler() {
                    private BroadcastReceiver chargingStateChangeReceiver;
                    @Override
                    public void onListen(Object arguments, EventSink events) {
                        chargingStateChangeReceiver = createChargingStateChangeReceiver(events);

                        IntentFilter mFilter = new IntentFilter(ACTION_SCANNER_RESULT);
                        registerReceiver(
                                chargingStateChangeReceiver, mFilter);
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        unregisterReceiver(chargingStateChangeReceiver);
                        chargingStateChangeReceiver = null;
                    }
                }
        );

        new MethodChannel(flutterEngine.getDartExecutor(), SCANQRCODE_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("scanQRCode"))
                        {
                            scanQRCode();
                            result.success("");
                        }
                        else {
                            result.notImplemented();
                        }
                    }
                }
        );
    }

    private BroadcastReceiver createChargingStateChangeReceiver(final EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                final String scanResult_1=intent.getStringExtra("SCAN_BARCODE1");
                final String scanResult_2=intent.getStringExtra("SCAN_BARCODE2");

                final String scanStatus = intent.getStringExtra(SCAN_STATE);
                events.success(SCAN_STATE_OK.equals(scanStatus)?(scanResult_1.length()>0?scanResult_1:scanResult_2):"Not Found.");
            }
        };
    }

    private void scanQRCode()
    {
        Intent intent = new Intent(ACTION_SCANNER_TRIG);
        //intent.putExtra("SCAN_TIMEOUT", 1);// SCAN_TIMEOUT value: int, 1-9; unit: second
        //intent.putExtra("SCAN_TYPE ", 1);// SCAN_TYPE: read two barcodes during a scan attempt
        sendBroadcast(intent);
    }

}
