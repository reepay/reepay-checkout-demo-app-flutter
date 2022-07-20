import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../main.dart';

class LocalCheckout extends StatefulWidget {
  const LocalCheckout({Key? key}) : super(key: key);

  @override
  State<LocalCheckout> createState() => _LocalCheckoutState();
}

class _LocalCheckoutState extends State<LocalCheckout> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Localhost Checkout"),
      ),
      body: Container(
        child: FutureBuilder(
          future: Future.delayed(
            const Duration(seconds: 3),
          ),
          builder: (context, s) => _isLoading == false
              ? InAppWebView(
                  initialData: InAppWebViewInitialData(
                    data: "http://localhost:8080/assets/index.html",
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useOnLoadResource: true,
                      userAgent:
                          "Mozilla/5.0 (Linux; Android 9; Redmi Note 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Mobile Safari/537.36",
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      allowUniversalAccessFromFileURLs: true,
                    ),
                    android: AndroidInAppWebViewOptions(
                      builtInZoomControls: true,
                      mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {},
                  onConsoleMessage: (InAppWebViewController controller, ConsoleMessage message) {
                    print("new msg:");

                    print(message.message.toString());

                    print(json.decode(message.message));
                  },
                )
              : const Text("Loading..."),
        ),
      ),
    );
  }

  @override
  void dispose() {
    localhostServer.close();
    super.dispose();
  }
}
