import 'dart:convert';

class RegisterRequest {
  final String fullname;
  final String identityNumber;
  final bool? confirmLinkRequest;
  final String email;
  final String phone;
  final String password;

  RegisterRequest({
    required this.fullname,
    required this.identityNumber,
    this.confirmLinkRequest,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'fullname': fullname,
      'identityNumber': identityNumber,
      'email': email,
      'phone': phone,
      'password': password,
    };
    if (confirmLinkRequest != null) {
      map['confirmLinkRequest'] = confirmLinkRequest;
    }
    return map;
  }

  String toJson() => JsonEncoder().convert(toMap());

  factory RegisterRequest.fromMap(Map<String, dynamic> map) {
    return RegisterRequest(
      fullname: map['fullname'] ?? '',
      identityNumber: map['identityNumber']?.toString() ?? '',
      confirmLinkRequest: map['confirmLinkRequest'] as bool?,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
