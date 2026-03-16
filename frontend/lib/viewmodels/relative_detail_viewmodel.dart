import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/data/repositories/record_repository.dart';

class RelativeDetailViewModel extends ChangeNotifier {
  RelativeDetailViewModel({required RecordRepository repository})
      : _repository = repository;

  final RecordRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  RelativeHistoryModel? history;
  String? _activeProfileId;

  String? get activeProfileId => _activeProfileId;

  Future<void> loadHistory(String profileId, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        history != null &&
        _activeProfileId == profileId &&
        !isLoading) {
      return;
    }

    final bool isSwitchingProfile = _activeProfileId != profileId;
    _activeProfileId = profileId;
    if (isSwitchingProfile) {
      history = null;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getHealthHistoryByProfileId(profileId);
      history = result;
      if (result == null) {
        errorMessage = 'Không tìm thấy dữ liệu sức khoẻ.';
      }
    } catch (_) {
      errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại sau.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String profileId) {
    return loadHistory(profileId, forceRefresh: true);
  }

  void clear() {
    history = null;
    errorMessage = null;
    _activeProfileId = null;
    isLoading = false;
    notifyListeners();
  }
}
