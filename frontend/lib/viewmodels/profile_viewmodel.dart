import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({required ProfileRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool _isFamilyLoading = false;
  String? _errorMessage;
  String? _familyErrorMessage;
  UserProfileModel? _profile;
  List<Relative> _familyProfiles = const [];

  bool get isLoading => _isLoading;
  bool get isFamilyLoading => _isFamilyLoading;
  String? get errorMessage => _errorMessage;
  String? get familyErrorMessage => _familyErrorMessage;
  UserProfileModel? get profile => _profile;
  List<Relative> get familyProfiles => List.unmodifiable(_familyProfiles);

  Future<void> loadOverview() async {
    _errorMessage = null;
    _familyErrorMessage = null;
    _setLoading(true);
    _setFamilyLoading(true);

    try {
      final results = await Future.wait([
        _repository.fetchMyProfile(),
        _repository.fetchFamilyProfiles(),
      ]);

      _profile = results[0] as UserProfileModel?;
      _familyProfiles = (results[1] as List<Relative>);

      if (_profile == null) {
        _errorMessage = 'Không thể tải thông tin của bạn lúc này.';
      }
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại sau.';
      _familyErrorMessage = 'Không thể tải hồ sơ người thân.';
    } finally {
      _setLoading(false);
      _setFamilyLoading(false);
    }
  }

  Future<void> reloadFamilyProfiles() async {
    _familyErrorMessage = null;
    _setFamilyLoading(true);

    try {
      _familyProfiles = await _repository.fetchFamilyProfiles();
    } catch (_) {
      _familyErrorMessage = 'Không thể tải hồ sơ người thân.';
    } finally {
      _setFamilyLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFamilyLoading(bool value) {
    _isFamilyLoading = value;
    notifyListeners();
  }
}
