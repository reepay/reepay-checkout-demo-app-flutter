class Customer {
  String firstName = "";
  String lastName = "";
  String address = "";
  String address2 = "";
  String phone = "";
  String email = "";

  Customer();

  Customer.fromJson(Map<String, dynamic> json)
      : firstName = json["first_name"],
        lastName = json["last_name"],
        address = json["address"],
        address2 = json["address2"],
        phone = json["phone"],
        email = json["email"];

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "address": address,
      "address2": address2,
      "phone": phone,
      "email": email,
    };
  }
}
