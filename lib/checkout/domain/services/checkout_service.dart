import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/bike_model.dart';
import '../models/customer_model.dart';
import '../repository/index.dart';

class CheckoutService implements CheckoutRepository {
  @override
  Future<List<Bike>> getBikeProducts() {
    var completer = Completer<List<Bike>>();

    List<Bike> bikes = [];

    var bike = Bike();
    bike.id = 1;
    bike.name = 'Orange Mountain Bike';
    bike.amount = 600;
    bike.currency = getCurrency();
    bike.url =
        'https://images.unsplash.com/photo-1511994298241-608e28f14fde?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8YmljeWNsZXxlbnwwfHwwfHw%3D&w=1000&q=80';
    bikes.add(bike);

    bike = Bike();
    bike.id = 2;
    bike.name = 'Blue Mountain Bike';
    bike.amount = 250;
    bike.currency = getCurrency();
    bike.url = 'https://cyclingindustry.news/wp-content/uploads/2019/09/img-bright.jpg';
    bikes.add(bike);

    bike = Bike();
    bike.id = 3;
    bike.name = 'Black Mountain Bike';
    bike.amount = 350;
    bike.currency = getCurrency();
    bike.url =
        'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmljeWNsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60';
    bikes.add(bike);

    completer.complete(bikes);

    return completer.future;
  }

  @override
  getCurrency() {
    return 'DKK';
  }

  Future<Map<String, dynamic>> getSessionUrl(String customerHandle, List<Map<String, Object>> orderlines) async {
    var completer = Completer<Map<String, dynamic>>();

    String apiUrl = dotenv.env['REEPAY_CHECKOUT_API_SESSION_CHARGE'] ?? '';
    if (apiUrl.isEmpty) {
      completer.complete({});
      return completer.future;
    }

    HttpClient client = HttpClient();
    HttpClientRequest request = await client.postUrl(Uri.parse(apiUrl));

    String apiKey = dotenv.env['REEPAY_PRIVATE_API_KEY']!;
    if (apiKey.isEmpty) (throw Exception("ERROR: Missing REEPAY_PRIVATE_API_KEY"));
    String encoded = base64.encode(utf8.encode(apiKey));
    request.headers.set("content-type", "application/json");
    request.headers.set("accept", "application/json");
    request.headers.set("Authorization", encoded);

    var orderNumber = DateTime.now().millisecondsSinceEpoch; // unique order identifer

    Map data = {
      "order": {
        "handle": 'order_flutter_$orderNumber',
        "customer": {
          "handle": customerHandle,
          // "first_name": 'John',
          // "last_name": 'Doe',
          // "phone": '+4511112222',
        },
        "currency": getCurrency(),
        "order_lines": orderlines,
      },
      "accept_url": 'https://sandbox.reepay.com/api/httpstatus/200/accept/order-$orderNumber',
      "cancel_url": 'https://sandbox.reepay.com/api/httpstatus/200/cancel/order-$orderNumber/'
      // "accept_url": 'reepaycheckout://?accept=true',
      // "cancel_url": 'reepaycheckout://?cancel=true'
    };

    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    client.close();

    Map<String, dynamic> result = jsonDecode(reply);
    completer.complete(result);
    return completer.future;
  }

  @override
  Future<String> getCustomerHandle() async {
    var completer = Completer<String>();

    String apiUrl = dotenv.env['REEPAY_API_CUSTOMER'] ?? '';
    if (apiUrl.isEmpty) (throw Exception("ERROR: Missing REEPAY_API_CUSTOMER"));
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.postUrl(Uri.parse(apiUrl));

    String apiKey = dotenv.env['REEPAY_PRIVATE_API_KEY']!;
    if (apiKey.isEmpty) return "ERROR: Missing REEPAY_PRIVATE_API_KEY";
    String encoded = base64.encode(utf8.encode(apiKey));
    request.headers.set("content-type", "application/json");
    request.headers.set("accept", "application/json");
    request.headers.set("Authorization", encoded);

    Map data = {"generate_handle": true};

    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    client.close();

    Map map = jsonDecode(reply);
    final handle = map['handle'];

    completer.complete(handle);
    return completer.future;
  }

  @override
  Future<bool> updateCustomer({required String customerHandle, required Customer customer}) async {
    var completer = Completer<bool>();

    HttpClient client = HttpClient();
    HttpClientRequest request = await client.putUrl(
      Uri.parse("https://api.reepay.com/v1/customer/$customerHandle"),
    );

    String encoded = base64.encode(utf8.encode(dotenv.env['REEPAY_PRIVATE_API_KEY'] as String));
    request.headers.set("content-type", "application/json");
    request.headers.set("accept", "application/json");
    request.headers.set("Authorization", encoded);

    Map data = customer.toJson();

    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();
    // String reply = await response.transform(utf8.decoder).join();
    client.close();

    // Map map = jsonDecode(reply);
    // print(map);

    final status = response.statusCode == 200 ? true : false;

    completer.complete(status);
    return completer.future;
  }
}
