import 'dart:convert';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }

  String toJson() => JsonEncoder().convert(toMap());

  factory LoginRequest.fromMap(Map<String, dynamic> map) {
    return LoginRequest(email: map['email'], password: map['password']);
  }
}
