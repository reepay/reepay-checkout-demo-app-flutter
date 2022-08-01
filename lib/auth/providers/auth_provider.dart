import 'package:localstore/localstore.dart';

import '../../checkout/domain/models/customer_model.dart';

class AuthProvider {
  final db = Localstore.instance;
  bool isSignInCustomer = false;

  static final AuthProvider _checkoutProvider = AuthProvider._internal();

  factory AuthProvider() {
    return _checkoutProvider;
  }

  AuthProvider._internal();

  Future<Map<String, dynamic>> getStorageCustomer() async {
    final Map<String, dynamic>? data = await db.collection('customerCollection').doc('customer').get();
    if (data != null) {
      // print(data['customer']);
      // print(data['handle']);
      Customer customer = Customer();
      String handle = '';
      data.forEach((key, value) {
        if (key == 'customer') {
          customer = Customer.fromJson(value);
        }
        if (key == 'handle') {
          handle = value;
        }
      });
      Map<String, dynamic> map = {};
      map['customer'] = customer;
      map['handle'] = handle;
      return map;
    }
    return {};
  }

  Future<void> setStorageCustomer(Customer customer) async {
    await db.collection('customerCollection').doc('customer').set({
      'customer': customer.toJson(),
      'handle': 'customer-flutter-1', // existing customer handle
    });
    isSignInCustomer = true;
  }

  Future<void> deleteStorageCustomer() async {
    await db.collection('customerCollection').doc('customer').delete();
    isSignInCustomer = false;
  }

  Future<void> setSignIn() async {
    Map data = await getStorageCustomer();
    isSignInCustomer = data.isNotEmpty ? true : false;
  }
}
