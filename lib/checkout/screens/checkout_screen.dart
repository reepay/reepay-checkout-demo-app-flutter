// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:reepay_demo_app/checkout/index.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../domain/models/bike_model.dart';

class CheckoutScreen extends StatefulWidget {
  CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  late Future<String> sessionData;

  @override
  void initState() {
    super.initState();
    sessionData = getSessionUrl(orderlines());
  }

  List<Map<String, Object>> orderlines() {
    if (CheckoutProvider().quantities.isEmpty) {
      return [
        {"amount": 10000, "ordertext": "Test checkout", "quantity": 2},
      ];
    }

    List<Map<String, Object>> orderLines = [];
    List<Bike> uniqueBikes = CheckoutProvider().cart.distinct((d) => d.id).toList();
    for (var element in uniqueBikes) {
      Map<String, Object> order = {
        "ordertext": element.name,
        "amount": element.amount * 100,
        "quantity": CheckoutProvider().quantities[element.name],
      };
      orderLines.add(order);
    }
    return orderLines;
  }

  Future<String> getSessionUrl(orderlines) async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.postUrl(
      Uri.parse("https://checkout-api.reepay.com/v1/session/charge"),
    );

    String encoded = base64.encode(utf8.encode("priv_b3aae30490f8f7792fc0ce659b2380f4"));
    request.headers.set("content-type", "application/json");
    request.headers.set("accept", "application/json");
    request.headers.set("Authorization", encoded);

    int randomOrderNumber = Random().nextInt(10000);

    // todo: specify user before checkout
    Map data = {
      "order": {
        "handle": 'order-test-$randomOrderNumber',
        "customer": {
          "handle": CheckoutProvider().customerHandle,
          // "first_name": 'John',
          // "last_name": 'Doe',
          // "phone": '+4511112222',
        },
        "order_lines": orderlines,
      },
      "accept_url": 'https://sandbox.reepay.com/api/httpstatus/200/accept/order-$randomOrderNumber',
      "cancel_url": 'https://sandbox.reepay.com/api/httpstatus/200/decline/order-$randomOrderNumber/'
    };

    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();
    // todo - check the response.statusCode
    String reply = await response.transform(utf8.decoder).join();
    client.close();
    return reply;
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
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> response = jsonDecode(snapshot.data);
                // print(response);
                return WebView(
                  initialUrl: Uri.dataFromString(getHtmlData(response["id"]), mimeType: 'text/html').toString(),
                  // initialUrl: response["url"],
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) async {
                    _controller.complete(webViewController);
                  },
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url != Uri.dataFromString(getHtmlData(response["id"]), mimeType: 'text/html').toString()) {
                      print('req: ${request.url}');
                    }

                    if (request.url.contains("decline")) {
                      print("user declined");
                      // Navigator.of(context).popUntil((route) => route.isFirst);
                      setState(() {
                        CheckoutProvider().setCart([]);
                      });
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                      return NavigationDecision.prevent;
                    } else if (request.url.contains("accept")) {
                      CheckoutService()
                          .updateCustomer(
                            customerHandle: CheckoutProvider().customerHandle,
                            customer: CheckoutProvider().customer,
                          )
                          .then(
                            (value) => print('update status: $value'),
                          );
                      setState(() {
                        CheckoutProvider().setCart([]);
                      });
                      print("user accepted");
                      Navigator.pushNamed(context, '/completed');
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
