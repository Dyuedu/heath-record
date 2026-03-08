import 'package:flutter/material.dart';
import 'package:frontend/data/models/doctor_model.dart';
import 'package:frontend/viewmodels/doctor_viewmodel.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DoctorViewModel>().fetchDoctors());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(vm),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.doctors.length,
                    itemBuilder: (context, index) => _DoctorCard(doctor: vm.doctors[index]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildFilterBar(DoctorViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Text("Sort By  ", style: TextStyle(fontWeight: FontWeight.bold)),
          // Nút A-Z / Z-A
          _filterItem(
            label: vm.isAscending ? "Z -> A" : "A -> Z", 
            isActive: vm.currentFilter == 'AZ',
            onTap: () => vm.sortByName(),
          ),
          _iconFilterItem(Icons.star, vm.currentFilter == 'Rating', () => vm.filterByRating()),
          _iconFilterItem(Icons.favorite, vm.currentFilter == 'Favorite', () => vm.filterByFavorite()),
          _iconFilterItem(Icons.female, vm.currentFilter == 'Female', () => vm.filterByGender(Gender.female)),
          _iconFilterItem(Icons.male, vm.currentFilter == 'Male', () => vm.filterByGender(Gender.male)),
        ],
      ),
    );
  }

  Widget _filterItem({required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF246BFF) : const Color(0xFFDDE3FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : const Color(0xFF246BFF), fontSize: 12)),
      ),
    );
  }

  Widget _iconFilterItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF246BFF) : const Color(0xFFDDE3FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF246BFF)),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white, elevation: 0,
      title: const Text("Doctors", style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Color(0xFF246BFF))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.tune, color: Color(0xFF246BFF))),
      ],
    );
  }
}

// Widget Doctor Card (Giữ nguyên style của bạn)
class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(doctor.imageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: const TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
                Text(doctor.specialty, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {}, 
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF246BFF), shape: const StadiumBorder(), elevation: 0),
                      child: const Text("Info", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, color: Color(0xFF246BFF), size: 16),
                    Text(" ${doctor.rating}", style: const TextStyle(color: Color(0xFF246BFF))),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}