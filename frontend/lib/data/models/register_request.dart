import 'dart:convert';

class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }

  String toJson() => JsonEncoder().convert(toMap());

  factory RegisterRequest.fromMap(Map<String, dynamic> map) {
    return RegisterRequest(email: map['email'], password: map['password']);
  }
}
