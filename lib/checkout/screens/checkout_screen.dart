// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reepay_checkout_flutter_example/checkout/domain/models/checkout_state_enum.dart';
import 'package:reepay_checkout_flutter_example/checkout/domain/models/user_action_enum.dart';
import 'package:reepay_checkout_flutter_example/checkout/index.dart';
import 'package:reepay_checkout_flutter_example/utils/event_parser.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CheckoutScreen extends StatefulWidget {
  final Future<Map<String, dynamic>>? sessionData;

  const CheckoutScreen({super.key, this.sessionData});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late WebViewController _controller;
  late Future<Map<String, dynamic>> sessionData;

  @override
  void initState() {
    super.initState();

    sessionData = widget.sessionData ??
        CheckoutService().getSessionUrl(
          CheckoutProvider().customerHandle,
          CheckoutProvider().orderlines(),
        );
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
              onAccept(hasCustomerInfo: true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel('CheckoutChannel', onMessageReceived: (JavaScriptMessage message) {
        _onMessageReceived(message);
      })
      ..loadRequest(Uri.parse(sessionUrl));

    _controller = controller;
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
  void onAccept({hasCustomerInfo = false}) {
    print("Payment success");
    if (hasCustomerInfo) {
      CheckoutService()
          .updateCustomer(
            customerHandle: CheckoutProvider().customerHandle,
            customer: CheckoutProvider().customer,
          )
          .then((value) => print('Status - update customer: $value'));
    }
    CheckoutProvider().setCart([]);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CompletedScreen()),
    );
  }

  /// Handle incoming messages from WebView
  void _onMessageReceived(JavaScriptMessage message) {
    print("[_onMessageReceived]: ${message.message}");

    Map<String, dynamic>? data;
    try {
      data = json.decode(message.message);
      final eventName = data!['event'];
      if (eventName is String) {
        final event = EventParser.parseEvent(eventName);
        if (event is EUserAction) {
          _handleUserActions(data);
        } else if (event is ECheckoutState) {
          _handleEvents(data);
        } else {
          throw ArgumentError('Invalid event type: $data');
        }
      } else {
        print('Undefined event: $data');
      }
    } catch (e) {
      print('[_onMessageReceived] Error: $e');
    }
  }

  void _handleEvents(data) {
    ECheckoutState event = ECheckoutState.fromString(data['event']);
    print('Event: $event');

    switch (event) {
      case ECheckoutState.init:
        _controller.runJavaScriptReturningResult('navigator.userAgent').then((result) {
          final userAgent = result.toString();
          final customUserAgent = '$userAgent ReepayCheckoutDemoApp/1.0.0 (Flutter)';
          final reply = {'userAgent': customUserAgent, 'isWebView': true};
          final jsCode = '''
            if (window.CheckoutChannel && typeof window.CheckoutChannel.resolveMessage === 'function') {
                window.CheckoutChannel.resolveMessage(${jsonEncode(reply)});
            } 
          ''';
          _controller.runJavaScript(jsCode);
        }).catchError((error) {
          print('Error retrieving user agent: $error');
        });
        break;
      case ECheckoutState.open:
      case ECheckoutState.close:
        break;
      case ECheckoutState.cancel:
        onCancel();
        break;
      case ECheckoutState.accept:
        onAccept();
        break;
      case ECheckoutState.error:
        print('Error: $data');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown event: $event')),
        );
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event: $data')),
    );
  }

  void _handleUserActions(data) {
    EUserAction action = EUserAction.fromString(data['event']);
    print('User Action: $action');

    switch (action) {
      case EUserAction.cardInputChange:
        final reply = {'isWebViewChanged': true};
        final jsCode = '''
            if (window.CheckoutChannel && typeof window.CheckoutChannel.resolveMessage === 'function') {
                window.CheckoutChannel.resolveMessage(${jsonEncode(reply)});
            } 
          ''';
        _controller.runJavaScript(jsCode);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown action: $action')),
        );
        return;
    }
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
