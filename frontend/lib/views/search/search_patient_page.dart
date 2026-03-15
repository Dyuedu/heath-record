import 'package:flutter/material.dart';
import 'package:frontend/views/search/patient_detail_page.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/doctor_viewmodel.dart';

class SearchPatientPage extends StatefulWidget {
  const SearchPatientPage({super.key});

  @override
  State<SearchPatientPage> createState() => _SearchPatientPageState();
}

class _SearchPatientPageState extends State<SearchPatientPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tìm kiếm bệnh nhân", 
          style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Nhập SĐT...",
                prefixIcon: const Icon(Icons.search, color: Color(0xff246b03ff)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF246BFF)),
                  onPressed: () {
                    context.read<DoctorViewModel>().searchPatient(_searchController.text);
                  },
                ),
                filled: true,
                fillColor: const Color(0xFFF0F3FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => context.read<DoctorViewModel>().searchPatient(value),
            ),
          ),

          // Kết quả tìm kiếm
          Expanded(
            child: Consumer<DoctorViewModel>(
              builder: (context, vm, child) {
                if (vm.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (vm.searchResults.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vm.searchResults.length,
                  itemBuilder: (context, index) {
                    final patient = vm.searchResults[index];
                    return _buildPatientCard(patient);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFDDE3FF)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF246BFF),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(patient.fullName, 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("SĐT: ${patient.phoneNumber}"),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF246BFF)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailPage(patient: patient),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Nhập thông tin để tìm bệnh nhân", 
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
