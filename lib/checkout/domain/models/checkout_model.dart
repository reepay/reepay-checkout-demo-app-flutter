// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CheckoutModel {
  String? s;
  int? n;
  CheckoutModel({
    this.s,
    this.n,
  });

  CheckoutModel copyWith({
    String? s,
    int? n,
  }) {
    return CheckoutModel(
      s: s ?? this.s,
      n: n ?? this.n,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      's': s,
      'n': n,
    };
  }

  factory CheckoutModel.fromMap(Map<String, dynamic> map) {
    return CheckoutModel(
      s: map['s'] != null ? map['s'] as String : null,
      n: map['n'] != null ? map['n'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CheckoutModel.fromJson(String source) => CheckoutModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CheckoutModel(s: $s, n: $n)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CheckoutModel &&
      other.s == s &&
      other.n == n;
  }

  @override
  int get hashCode => s.hashCode ^ n.hashCode;
}
