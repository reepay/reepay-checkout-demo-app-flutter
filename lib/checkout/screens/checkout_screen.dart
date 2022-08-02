// ignore_for_file: prefer_const_constructors
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reepay_checkout_flutter_example/checkout/index.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

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
      body: Container(
        child: Center(
          child: FutureBuilder(
            future: sessionData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
                print("ERROR: Missing environment variables!");
              }

              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                Map<String, dynamic> response = snapshot.data as Map<String, dynamic>;
                // print(response);
                return WebView(
                  initialUrl: Uri.dataFromString(getHtmlData(response["id"]), mimeType: 'text/html').toString(),
                  // initialUrl: response["url"],
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) async {
                    _controller.complete(webViewController);
                  },
                  navigationDelegate: (NavigationRequest request) {
                    // listen to url changes
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
                );
              }
              return Text("Loading...");
            },
          ),
        ),
      ),
    );
  }

  /// cancel handler
  void onCancel() {
    print("Payment failed");
    setState(() {
      CheckoutProvider().setCart([]);
    });
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  /// accept handler
  void onAccept() {
    print("Payment success");
    CheckoutService()
        .updateCustomer(
          customerHandle: CheckoutProvider().customerHandle,
          customer: CheckoutProvider().customer,
        )
        .then(
          (value) => print('Status - update customer: $value'),
        );
    setState(() {
      CheckoutProvider().setCart([]);
    });
    Navigator.pushNamed(context, '/completed');
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
