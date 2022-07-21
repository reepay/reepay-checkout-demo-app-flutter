import 'package:flutter/material.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({Key? key}) : super(key: key);

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text("Purchase completed"),
          ),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.amber,
                  primary: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
                child: const Text(
                  'Back to shopping',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
