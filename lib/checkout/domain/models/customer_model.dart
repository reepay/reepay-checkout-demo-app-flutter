// ignore_for_file: non_constant_identifier_names

class Customer {
  String first_name = "";
  String last_name = "";
  String address = "";
  String address2 = "";
  String phone = "";
  String email = "";

  Customer();

  Customer.fromJson(Map<String, dynamic> json)
      : first_name = json["first_name"],
        last_name = json["last_name"],
        address = json["address"],
        address2 = json["address2"],
        phone = json["phone"],
        email = json["email"];

  Map<String, dynamic> toJson() {
    return {
      "first_name": first_name,
      "last_name": last_name,
      "address": address,
      "address2": address2,
      "phone": phone,
      "email": email,
    };
  }
}
