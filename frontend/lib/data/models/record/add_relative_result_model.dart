import 'package:frontend/data/models/record/relative.dart';

class AddRelativeResultModel {
  final String status;
  final String? requestId;
  final String message;
  final Relative? relative;

  const AddRelativeResultModel({
    required this.status,
    this.requestId,
    required this.message,
    this.relative,
  });

  bool get isCreated => status == 'CREATED';
  bool get isLinkRequestCreated => status == 'LINK_REQUEST_CREATED';

  factory AddRelativeResultModel.fromMap(Map<String, dynamic> map) {
    final relativeRaw = map['relative'];
    return AddRelativeResultModel(
      status: map['status']?.toString() ?? 'CREATED',
      requestId: map['requestId']?.toString(),
      message: map['message']?.toString() ?? '',
      relative: relativeRaw is Map<String, dynamic>
          ? Relative.fromMap(relativeRaw)
          : null,
    );
  }

  factory AddRelativeResultModel.fallbackCreated(Relative? relative) {
    return AddRelativeResultModel(
      status: 'CREATED',
      requestId: null,
      message: 'Thêm hồ sơ thành công',
      relative: relative,
    );
  }
}
