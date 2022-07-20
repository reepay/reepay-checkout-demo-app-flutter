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

  Future<void> fetchData({required String n}) async {
    final _data = List.generate(3, ((index) => index + 1));
    data = _data;
    // TODO: Notify Listeners
  }

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

  Future<void> getCustomerHandle() async {
    customerHandle = await CheckoutService().getCustomerHandle();
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
    print('provider: quantities $quantities');
    return quantities;
  }

  Future<void> getCart() async {
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
    await db.collection('cartCollection').doc('cart').set({
      'cart': cart,
    });
    this.cart = cart;
  }
}
