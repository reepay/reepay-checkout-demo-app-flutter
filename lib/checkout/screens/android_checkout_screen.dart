import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidCheckoutScreen extends StatefulWidget {
  const AndroidCheckoutScreen({Key? key}) : super(key: key);

  @override
  State<AndroidCheckoutScreen> createState() => _AndroidCheckoutScreenState();
}

class _AndroidCheckoutScreenState extends State<AndroidCheckoutScreen> {
  static const platform = MethodChannel('TEST_CHANNEL');

  void initState() {
    super.initState();
    test();
  }

  void test() async {
    var sharedData = await platform.invokeMethod("test");
    if (sharedData != null) {
      setState(() {
        print(sharedData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android WebView Example'),
      ),
      body: const AndroidView(
        viewType: "view1",
      ),
    );
  }
}
