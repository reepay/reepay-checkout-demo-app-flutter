import 'dart:async';

import '../models/bike_model.dart';
import '../repository/index.dart';

class CheckoutService implements CheckoutRepository {
  @override
  Future<int?> someFunctionName({required String s}) async {
    // TODO: implement function
    throw UnimplementedError();
  }

  @override
  Future<List<Bike>> getBikeProducts() {
    var completer = Completer<List<Bike>>();

    List<Bike> bikes = [];

    var bike = Bike();
    bike.id = 1;
    bike.name = 'Premium Mountain Bike';
    bike.amount = 6000;
    bike.url =
        'https://images.unsplash.com/photo-1511994298241-608e28f14fde?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8YmljeWNsZXxlbnwwfHwwfHw%3D&w=1000&q=80';
    bikes.add(bike);

    bike = Bike();
    bike.id = 2;
    bike.name = 'Blue Mountain Bike';
    bike.amount = 2500;
    bike.url =
        'https://cyclingindustry.news/wp-content/uploads/2019/09/img-bright.jpg';
    bikes.add(bike);

    bike = Bike();
    bike.id = 3;
    bike.name = 'Black Mountain Bike';
    bike.amount = 3500;
    bike.url =
        'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmljeWNsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60';
    bikes.add(bike);

    completer.complete(bikes);

    return completer.future;
  }
}
