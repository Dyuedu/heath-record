import 'dart:convert';

class RegisterRequest {
  final String fullname;
  final String email;
  final String phone;
  final String password;

  RegisterRequest({
    required this.fullname,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  String toJson() => JsonEncoder().convert(toMap());

  factory RegisterRequest.fromMap(Map<String, dynamic> map) {
    return RegisterRequest(
      fullname: map['fullname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
    );
  }
}