import 'package:flutter/material.dart';
import '../data/models/doctor/doctor_model.dart';
import '../data/repositories/user_repository.dart';

class DoctorViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  List<DoctorModel> _allDoctors = [];
  List<DoctorModel> _displayDoctors = [];
  List<String> _departments = [];
  bool isLoading = false;
  bool isAscending = true;
  String currentFilter = 'AZ';
  String searchQuery = '';
  bool _hasLoaded = false;
  String? errorMessage;
  String? _selectedDepartment;

  DoctorViewModel({required UserRepository repository})
    : _userRepository = repository;

  List<DoctorModel> get doctors => _displayDoctors;
  List<String> get departments => List.unmodifiable(_departments);
  String? get selectedDepartment => _selectedDepartment;

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
      _departments = _buildDepartments(_allDoctors);
      if (_selectedDepartment != null &&
          !_departments.contains(_selectedDepartment!)) {
        _selectedDepartment = null;
      }
      _applyCurrentFilter(notify: false);
      _hasLoaded = true;
    } catch (error) {
      errorMessage = 'Không thể tải danh sách bác sĩ: $error';
      _allDoctors = [];
      _displayDoctors = [];
      _departments = [];
      _selectedDepartment = null;
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

  void setDepartmentFilter(String? department) {
    final normalized = department?.trim();
    final resolved = normalized == null || normalized.isEmpty
        ? null
        : normalized;
    if (_selectedDepartment == resolved) {
      return;
    }
    _selectedDepartment = resolved;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter({Gender? gender, bool notify = true}) {
    List<DoctorModel> working = List.from(_allDoctors);

    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      final target = _selectedDepartment!.toLowerCase();
      working = working
          .where((doc) => doc.specialty.trim().toLowerCase() == target)
          .toList();
    }

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
                doc.contactEmail.toLowerCase().contains(q),
          )
          .toList();
    }

    _displayDoctors = working;
    if (notify) notifyListeners();
  }

  List<String> _buildDepartments(List<DoctorModel> doctors) {
    final set = <String>{};
    for (final doctor in doctors) {
      final department = doctor.specialty.trim();
      if (department.isNotEmpty) {
        set.add(department);
      }
    }
    final list = set.toList()..sort((a, b) => a.compareTo(b));
    return list;
  }

  int _compareByName(DoctorModel a, DoctorModel b) {
    return isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
  }
}
