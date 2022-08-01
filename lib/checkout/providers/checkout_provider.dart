import 'package:darq/darq.dart';
import 'package:localstore/localstore.dart';
import 'package:reepay_demo_app/checkout/domain/services/checkout_service.dart';

import '../domain/models/bike_model.dart';
import '../domain/models/customer_model.dart';

class CheckoutProvider {
  final db = Localstore.instance;
  List<int?> data = [];
  List<Bike> cart = [];
  dynamic quantities = {};
  String customerHandle = '';
  Customer customer = Customer();

  static final CheckoutProvider _checkoutProvider = CheckoutProvider._internal();

  factory CheckoutProvider() {
    return _checkoutProvider;
  }

  CheckoutProvider._internal();

  Future<dynamic> getUniqueBikes() async {
    List<Bike> uniqueBikes = cart.distinct((d) => d.id).toList();
    int total = 0;
    var quantities = getQuantities(cart);
    for (var item in cart) {
      item.quantity = quantities[item.name];
    }
    for (var item in uniqueBikes) {
      total = total + (item.quantity * item.amount);
    }
    return {'uniqueBikes': uniqueBikes, 'total': total};
  }

  Future<void> setCustomerHandle(String handle) async {
    if (handle.isEmpty) {
      customerHandle = await CheckoutService().getCustomerHandle();
      return;
    }
    customerHandle = handle;
    print('created customer handle: $customerHandle');
  }

  Future<void> setCustomer(Customer customer) async {
    this.customer = customer;
  }

  dynamic getQuantities(cart) {
    quantities = {};
    cart.forEach(
      ((item) => {
            if (quantities[item.name] == null)
              {
                quantities[item.name] = 1,
              }
            else
              {
                quantities[item.name]++,
              }
          }),
    );
    // print('provider: quantities $quantities');
    return quantities;
  }

  Future<void> getCart() async {
    cart = [];
    final data = await db.collection('cartCollection').doc('cart').get();
    if (data != null) {
      data.forEach((key, value) {
        List<dynamic> list = value;
        for (var element in list) {
          cart.add(Bike.fromJson(element));
        }
      });
      print("provider: cart: ${cart.length}");
    }
  }

  Future<void> setCart(List<Bike> cart) async {
    List<Map<String, dynamic>> list = [];
    for (Bike bike in cart) {
      list.add(bike.toJson());
    }
    await db.collection('cartCollection').doc('cart').set({
      'cart': list,
    });
    this.cart = cart;
  }

  /// Example of orders
  List<Map<String, Object>> orderlines() {
    if (CheckoutProvider().quantities.isEmpty) {
      return [
        {"amount": 10000, "ordertext": "Flutter Product", "quantity": 2},
      ];
    }

    List<Map<String, Object>> orderLines = [];
    List<Bike> uniqueBikes = cart.distinct((d) => d.id).toList();
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
}
