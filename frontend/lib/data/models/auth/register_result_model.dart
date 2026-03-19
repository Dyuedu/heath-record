class RegisterResultModel {
  final String status;
  final String? requestId;
  final String message;

  const RegisterResultModel({
    required this.status,
    this.requestId,
    required this.message,
  });

  bool get isRegistered => status == 'REGISTERED';
  bool get isLinkRequestCreated => status == 'LINK_REQUEST_CREATED';
  bool get isConfirmRequired => status == 'PROFILE_EXISTS_CONFIRM_REQUIRED';

  factory RegisterResultModel.fromMap(Map<String, dynamic> map) {
    return RegisterResultModel(
      status: map['status']?.toString() ?? 'REGISTERED',
      requestId: map['requestId']?.toString(),
      message: map['message']?.toString() ?? '',
    );
  }

  factory RegisterResultModel.fallbackSuccess() {
    return const RegisterResultModel(
      status: 'REGISTERED',
      requestId: null,
      message: 'Đăng ký thành công',
    );
  }
}
