import 'package:localstore/localstore.dart';

import '../domain/models/bike_model.dart';

class CheckoutProvider {
  List<int?> data = [];
  List<Bike> cart = [];
  final db = Localstore.instance;

  static final CheckoutProvider _checkoutProvider =
      CheckoutProvider._internal();

  factory CheckoutProvider() {
    return _checkoutProvider;
  }

  CheckoutProvider._internal();

  Future<void> fetchData({required String n}) async {
    final _data = List.generate(3, ((index) => index + 1));
    data = _data;
    // TODO: Notify Listeners
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
      print("cart: ${cart.length}");
    }
  }

  Future<void> setCart(List<Bike> cart) async {
    db.collection('cartCollection').doc('cart').set({
      'cart': cart,
    });
    this.cart = cart;
  }
}
