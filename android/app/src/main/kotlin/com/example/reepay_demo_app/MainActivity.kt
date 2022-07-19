package com.example.reepay_demo_app

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    companion object {
        var flutterEngineInstance: FlutterEngine? = null
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        super.configureFlutterEngine(flutterEngine)

        flutterEngine
                .platformViewsController
                .registry
                .registerViewFactory("view1", NativeViewFactory())

        flutterEngine
                .dartExecutor
                .executeDartEntrypoint(
                        DartExecutor.DartEntrypoint.createDefault()
                )

        flutterEngineInstance = flutterEngine

        /*MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "TEST_CHANNEL").setMethodCallHandler { call, result ->
            if (call.method!!.contentEquals("test")) {
                result.success("Shared Text")
            }
        }*/
    }
}
