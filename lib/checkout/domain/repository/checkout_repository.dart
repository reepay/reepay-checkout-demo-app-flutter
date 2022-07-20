import 'dart:async';

import '../models/bike_model.dart';
import '../models/customer_model.dart';

abstract class CheckoutRepository {
  const CheckoutRepository();

  Future<int?> someFunctionName({required String s});

  Future<List<Bike>>? getBikeProducts();

  Future<String> getCustomerHandle();

  Future<bool> updateCustomer({required String customerHandle, required Customer customer});
}
