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
  bool isAscending = true; // true = A → Z
  String currentFilter = 'AZ';
  String searchQuery = '';

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
        experienceYears: 15,
        reviewCount: 86,
        availability: 'Mon-Sat / 9:00AM - 5:00PM',
        profile: 'Dr. Turner bridges dermatology and endocrinology to treat complex hormonal skin disorders.',
        careerPath: 'Graduated from Stanford Medical School, fellowship at Mayo Clinic, now leading Dermato-Endocrinology at Aurora Care.',
        highlights: 'Published 24 peer-reviewed papers and leads a tele-dermatology initiative for remote patients.',
        availableSlots: const ['09:00 AM', '09:30 AM', '10:00 AM', '11:00 AM', '02:00 PM'],
        contactEmail: 'olivia.turner@auroracare.com',
        contactPhone: '+1 202 123 4567',
      ),
      DoctorModel(
        id: '2',
        name: "Dr. Alexander Bennett",
        specialty: "Dermato-Genetics",
        rating: 4.8,
        heartCount: 80,
        gender: Gender.male,
        imageUrl: "https://via.placeholder.com/150",
        experienceYears: 12,
        reviewCount: 65,
        availability: 'Tue-Sun / 10:00AM - 6:00PM',
        profile: 'Focuses on genetic counseling for chronic skin disorders and personalized treatment maps.',
        careerPath: 'Oxford alum with research tenure at MIT Media Lab, now consulting for multiple bio-tech startups.',
        highlights: 'Awarded National Science Foundation grant for gene-mapping acne therapies.',
        availableSlots: const ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:30 AM'],
        contactEmail: 'alexander.bennett@auroracare.com',
        contactPhone: '+1 202 456 8890',
      ),
      DoctorModel(
        id: '3',
        name: "Dr. Sophia Martinez",
        specialty: "Cosmetic Bioengineering",
        rating: 4.9,
        heartCount: 120,
        gender: Gender.female,
        imageUrl: "https://via.placeholder.com/150",
        experienceYears: 10,
        reviewCount: 102,
        availability: 'Mon-Fri / 8:00AM - 4:00PM',
        profile: 'Designs regenerative therapies blending biotech with aesthetic dermatology.',
        careerPath: 'Former researcher at Seoul BioLab, now directing regenerative skincare programs at Aurora.',
        highlights: 'Pioneer of collagen micro-grafting technique adopted in 12 clinics worldwide.',
        availableSlots: const ['08:30 AM', '09:00 AM', '01:00 PM', '03:30 PM', '04:00 PM'],
        contactEmail: 'sophia.martinez@auroracare.com',
        contactPhone: '+1 202 223 7711',
      ),
      DoctorModel(
        id: '4',
        name: "Dr. Michael Davidson",
        specialty: "Solar Dermatology",
        rating: 4.7,
        heartCount: 60,
        gender: Gender.male,
        imageUrl: "https://via.placeholder.com/150",
        experienceYears: 18,
        reviewCount: 58,
        availability: 'Mon-Sat / 11:00AM - 7:00PM',
        profile: 'Protects outdoor athletes and defense teams with tailored sun-damage protocols.',
        careerPath: 'Served as NASA clinical consultant, currently head of Solar Dermatology at Aurora.',
        highlights: 'Runs a nationwide program monitoring UV impact on service members.',
        availableSlots: const ['11:00 AM', '12:30 PM', '02:30 PM', '04:30 PM', '06:00 PM'],
        contactEmail: 'michael.davidson@auroracare.com',
        contactPhone: '+1 202 987 6600',
      ),
    ];

    _applyCurrentFilter(notify: false);
    isLoading = false;
    notifyListeners();
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
        final Gender target = gender ?? (currentFilter == 'Male' ? Gender.male : Gender.female);
        working = working.where((doc) => doc.gender == target).toList();
        working.sort((a, b) => _compareByName(a, b));
        break;
      default:
        working.sort((a, b) => _compareByName(a, b));
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      working = working
          .where((doc) =>
              doc.name.toLowerCase().contains(q) ||
              doc.specialty.toLowerCase().contains(q))
          .toList();
    }

    _displayDoctors = working;
    if (notify) this.notifyListeners();
  }

  int _compareByName(DoctorModel a, DoctorModel b) {
    return isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
  }
}
