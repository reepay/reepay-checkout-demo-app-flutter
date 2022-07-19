import 'dart:async';

import '../models/bike_model.dart';

abstract class CheckoutRepository {
  const CheckoutRepository();

  Future<int?> someFunctionName({required String s});

  Future<List<Bike>>? getBikeProducts();
}
