import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/user/doctor_patient_records_page.dart';
import 'package:provider/provider.dart';

class DoctorUserSearchPage extends StatefulWidget {
  const DoctorUserSearchPage({super.key});

  @override
  State<DoctorUserSearchPage> createState() => _DoctorUserSearchPageState();
}

class _DoctorUserSearchPageState extends State<DoctorUserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onKeywordChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<ProfileViewModel>().searchPatientsForDoctor(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Tìm người dùng',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF246BFF)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: vm.searchPatientsForDoctor,
                    onChanged: _onKeywordChanged,
                    decoration: InputDecoration(
                      hintText: 'Nhập CCCD hoặc SĐT...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => vm.searchPatientsForDoctor(
                    _searchController.text,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF246BFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(56, 50),
                  ),
                  child: const Text('Tìm'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (vm.isDoctorSearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.doctorSearchResults.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nhập CCCD/SĐT để tìm người dùng.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: vm.doctorSearchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = vm.doctorSearchResults[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE0E6FF)),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE0E6FF),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF246BFF),
                            ),
                          ),
                          title: Text(
                            user.fullName.isEmpty
                                ? 'Không rõ tên'
                                : user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CCCD: ${user.identityNumber.isEmpty ? 'Chưa cập nhật' : user.identityNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'SĐT: ${user.phoneNumber.isEmpty ? 'Chưa cập nhật' : user.phoneNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorPatientRecordsPage(
                                  patientId: user.id,
                                  patientName: user.fullName,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
