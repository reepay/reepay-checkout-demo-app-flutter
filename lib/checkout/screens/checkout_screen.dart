// ignore_for_file: prefer_const_constructors
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reepay_checkout_flutter_example/checkout/index.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<Map> sessionData;

  @override
  void initState() {
    super.initState();
    sessionData = CheckoutService().getSessionUrl(CheckoutProvider().customerHandle, CheckoutProvider().orderlines());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Window'),
      ),
      body: Center(
        child: FutureBuilder(
          future: sessionData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
              print("ERROR: Missing environment variables!");
            }

            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              Map<String, dynamic> response = snapshot.data as Map<String, dynamic>;
              // print(response);

              final String sessionUrl = response["url"];
              // final String sessionUrl = 'https://staging-checkout.reepay.com/#/checkout/cs_8890be9db09b0ffcefaebbfb1bee05a0'; // todo: google/apple pay
              // final String sessionUrl = Uri.dataFromString(getHtmlData(response["id"]), mimeType: 'text/html').toString(); // todo: using html template

              final WebViewController webViewController = getWebViewController(sessionUrl);
              final WebViewWidget webViewWidget = WebViewWidget.fromPlatformCreationParams(
                params: getWebViewWidgetParams(webViewController),
              );

              return webViewWidget;
            }
            return Text("Loading...");
          },
        ),
      ),
    );
  }

  WebViewController getWebViewController(String sessionUrl) {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            print('Error Url: ${error.url}');
            print('Error Description: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Listen to url changes
            // if (request.url != Uri.dataFromString(getHtmlData(response["id"]), mimeType: 'text/html').toString()) {
            //   print('req: ${request.url}');
            // }
            if (request.url.contains("cancel")) {
              onCancel();
              return NavigationDecision.prevent;
            } else if (request.url.contains("accept")) {
              onAccept();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(sessionUrl));
    return controller;
  }

  PlatformWebViewWidgetCreationParams getWebViewWidgetParams(WebViewController controller) {
    PlatformWebViewWidgetCreationParams params = PlatformWebViewWidgetCreationParams(
      controller: controller.platform,
      layoutDirection: TextDirection.ltr,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
        params,
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
        params,
      );
    }

    return params;
  }

  /// cancel handler
  void onCancel() {
    print("Payment failed");
    CheckoutProvider().setCart([]);
    Navigator.popAndPushNamed(context, '/');
  }

  /// accept handler
  void onAccept() {
    print("Payment success");
    CheckoutService()
        .updateCustomer(
          customerHandle: CheckoutProvider().customerHandle,
          customer: CheckoutProvider().customer,
        )
        .then((value) => print('Status - update customer: $value'));
    CheckoutProvider().setCart([]);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CompletedScreen()),
    );
  }

  ///
  /// Return HTML template with Reepay Window Checkout element.
  /// (Alternatively, use session url directly in webview)
  ///
  String getHtmlData(String id) {
    return """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <script src="https://checkout.reepay.com/checkout.js"></script>
      </head>
      <body>
        <div id="rp_container" style="min-width: 300px; width: 100%; height: 600px; margin: auto;"></div>
        <script>
          var rp = new Reepay.WindowCheckout("$id", { html_element: "rp_container" });
        </script>
      </body>
      </html>
    """;
  }
}
