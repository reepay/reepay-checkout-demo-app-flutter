class Bike {
  int id = 0;
  String name = "";
  int amount = 0;
  String url = "";
  int quantity = 0;

  Bike();

  Bike.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        amount = json['amount'],
        url = json['url'],
        quantity = json['quantity'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'url': url,
      'quantity': quantity,
    };
  }
}
