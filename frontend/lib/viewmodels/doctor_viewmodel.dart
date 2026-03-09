import 'package:flutter/material.dart';
import 'package:frontend/data/models/patient/patient_model.dart';
import 'package:frontend/data/repositories/doctor_repository.dart';
import '../data/models/doctor/doctor_model.dart';

class DoctorViewModel extends ChangeNotifier {
  final DoctorRepository _repository;
  List<DoctorModel> _allDoctors = []; // Dữ liệu gốc từ API
  List<DoctorModel> _displayDoctors = []; // Dữ liệu đã lọc/sắp xếp để hiển thị
  List<PatientModel> searchResults = [];
  bool isSearching = false;
  bool isLoading = false;
  bool isAscending = true; // Theo dõi trạng thái A-Z hoặc Z-A
  String currentFilter = 'AZ';

  DoctorViewModel({required DoctorRepository repository})
    : _repository = repository; // AZ, Rating, Favorite, Male, Female

  List<DoctorModel> get doctors => _displayDoctors;

  Future<void> searchPatient(String phone) async {
    if (phone.isEmpty) return;

    isSearching = true;
    notifyListeners();

    searchResults = await _repository.searchPatientByPhone(phone);

    isSearching = false;
    notifyListeners();
  }

  Future<void> fetchDoctors() async {
    isLoading = true;
    notifyListeners();

    // Giả lập dữ liệu từ Backend Spring
    await Future.delayed(const Duration(milliseconds: 500));
    _allDoctors = [
      DoctorModel(
        id: '1',
        name: "Dr. Olivia Turner",
        specialty: "Dermato-Endocrinology",
        rating: 5.0,
        heartCount: 100,
        gender: Gender.female,
        imageUrl: "https://via.placeholder.com/150",
      ),
      DoctorModel(
        id: '2',
        name: "Dr. Alexander Bennett",
        specialty: "Dermato-Genetics",
        rating: 4.8,
        heartCount: 80,
        gender: Gender.male,
        imageUrl: "https://via.placeholder.com/150",
      ),
      DoctorModel(
        id: '3',
        name: "Dr. Sophia Martinez",
        specialty: "Cosmetic Bioengineering",
        rating: 4.9,
        heartCount: 120,
        gender: Gender.female,
        imageUrl: "https://via.placeholder.com/150",
      ),
      DoctorModel(
        id: '4',
        name: "Dr. Michael Davidson",
        specialty: "Solar Dermatology",
        rating: 4.7,
        heartCount: 60,
        gender: Gender.male,
        imageUrl: "https://via.placeholder.com/150",
      ),
    ];

    _displayDoctors = List.from(_allDoctors);
    sortByName(); // Mặc định sắp xếp A-Z
    isLoading = false;
    notifyListeners();
  }

  // 1. Logic Sắp xếp A-Z và Z-A
  void sortByName() {
    currentFilter = 'AZ';
    if (isAscending) {
      _displayDoctors.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _displayDoctors.sort((a, b) => b.name.compareTo(a.name));
    }
    isAscending = !isAscending; // Đảo chiều cho lần nhấn sau
    notifyListeners();
  }

  // 2. Logic Lọc theo Rating (Giảm dần)
  void filterByRating() {
    currentFilter = 'Rating';
    _displayDoctors = List.from(_allDoctors);
    _displayDoctors.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  // 3. Logic Lọc theo mức độ ưa thích (Số tim giảm dần)
  void filterByFavorite() {
    currentFilter = 'Favorite';
    _displayDoctors = List.from(_allDoctors);
    _displayDoctors.sort((a, b) => b.heartCount.compareTo(a.heartCount));
    notifyListeners();
  }

  // 4. Logic Lọc theo Giới tính
  void filterByGender(Gender gender) {
    currentFilter = gender == Gender.male ? 'Male' : 'Female';
    _displayDoctors = _allDoctors.where((doc) => doc.gender == gender).toList();
    notifyListeners();
  }
}
