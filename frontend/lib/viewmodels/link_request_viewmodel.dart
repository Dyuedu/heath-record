import 'package:flutter/material.dart';
import 'package:frontend/data/models/link_request/link_request_model.dart';
import 'package:frontend/data/repositories/link_request_repository.dart';

class LinkRequestViewModel extends ChangeNotifier {
  final LinkRequestRepository _repository;

  LinkRequestViewModel({required LinkRequestRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool _isActing = false;
  String? _errorMessage;
  List<LinkRequestModel> _inboxRequests = const [];

  bool get isLoading => _isLoading;
  bool get isActing => _isActing;
  String? get errorMessage => _errorMessage;
  List<LinkRequestModel> get inboxRequests => List.unmodifiable(_inboxRequests);

  Future<void> loadInbox({String status = 'PENDING'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _inboxRequests = await _repository.getInbox(status: status);
    } catch (_) {
      _errorMessage = 'Không thể tải danh sách yêu cầu liên kết.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String requestId) async {
    return _executeAction(() => _repository.approve(requestId));
  }

  Future<bool> reject(String requestId) async {
    return _executeAction(() => _repository.reject(requestId));
  }

  Future<bool> cancel(String requestId) async {
    return _executeAction(() => _repository.cancel(requestId));
  }

  Future<bool> _executeAction(Future<bool> Function() action) async {
    _isActing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await action();
      if (!success) {
        _errorMessage = 'Không thể xử lý yêu cầu. Vui lòng thử lại.';
      }
      return success;
    } catch (_) {
      _errorMessage = 'Không thể xử lý yêu cầu. Vui lòng thử lại.';
      return false;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }
}
