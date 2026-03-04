import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/register_request.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  RegisterViewModel({required this.authRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _errorMessage;
  Map<String, dynamic>? get errorMessage => _errorMessage;

  set errorMessage(Map<String, dynamic>? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.register(RegisterRequest(email: email, password: password));
      return true;
    } catch (e) {
      if (e is Map<String, dynamic>) {
        _errorMessage = e; // Lưu Map {'email': '...', 'password': '...'}
      } else {
        // Xử lý lỗi chung (mất mạng, server 500...)
        _errorMessage = {'general': e.toString()};
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }
}
