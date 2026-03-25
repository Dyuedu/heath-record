import 'package:flutter/material.dart';
import '../data/models/doctor/doctor_model.dart';
import '../data/repositories/user_repository.dart';

class DoctorViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  List<DoctorModel> _allDoctors = [];
  List<DoctorModel> _displayDoctors = [];
  bool isLoading = false;
  bool isAscending = true;
  String currentFilter = 'AZ';
  String searchQuery = '';
  bool _hasLoaded = false;
  String? errorMessage;

  DoctorViewModel({required UserRepository repository})
    : _userRepository = repository;

  List<DoctorModel> get doctors => _displayDoctors;

  Future<void> fetchDoctors({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await _userRepository.fetchDoctors();
      _allDoctors = results
          .map((profile) => DoctorModel.fromUserProfile(profile))
          .toList();
      _applyCurrentFilter(notify: false);
      _hasLoaded = true;
    } catch (error) {
      errorMessage = 'Không thể tải danh sách bác sĩ: $error';
      _allDoctors = [];
      _displayDoctors = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 1. Logic Sắp xếp A-Z và Z-A
  void sortByName() {
    currentFilter = 'AZ';
    isAscending = !isAscending;
    _applyCurrentFilter();
  }

  // 2. Logic Lọc theo Rating (Giảm dần)
  void filterByRating() {
    currentFilter = 'Rating';
    _applyCurrentFilter();
  }

  // 3. Logic Lọc theo mức độ ưa thích (Số tim giảm dần)
  void filterByFavorite() {
    currentFilter = 'Favorite';
    _applyCurrentFilter();
  }

  // 4. Logic Lọc theo Giới tính
  void filterByGender(Gender gender) {
    currentFilter = gender == Gender.male ? 'Male' : 'Female';
    _applyCurrentFilter(gender: gender);
  }

  void updateSearchQuery(String query) {
    searchQuery = query.trim();
    _applyCurrentFilter();
  }

  void _applyCurrentFilter({Gender? gender, bool notify = true}) {
    List<DoctorModel> working = List.from(_allDoctors);

    switch (currentFilter) {
      case 'Rating':
        working.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Favorite':
        working.sort((a, b) => b.heartCount.compareTo(a.heartCount));
        break;
      case 'Male':
      case 'Female':
        final Gender target =
            gender ?? (currentFilter == 'Male' ? Gender.male : Gender.female);
        working = working.where((doc) => doc.gender == target).toList();
        working.sort((a, b) => _compareByName(a, b));
        break;
      default:
        working.sort((a, b) => _compareByName(a, b));
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      working = working
          .where(
            (doc) =>
                doc.name.toLowerCase().contains(q) ||
                doc.specialty.toLowerCase().contains(q),
          )
          .toList();
    }

    _displayDoctors = working;
    if (notify) this.notifyListeners();
  }

  int _compareByName(DoctorModel a, DoctorModel b) {
    return isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
  }
}
