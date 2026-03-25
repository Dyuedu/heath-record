import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/doctor/doctor_patient_detail_page.dart';
import 'package:provider/provider.dart';

class DoctorUserSearchPage extends StatefulWidget {
  const DoctorUserSearchPage({super.key});

  @override
  State<DoctorUserSearchPage> createState() => _DoctorUserSearchPageState();
}

class _DoctorUserSearchPageState extends State<DoctorUserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _hasSearched = false;
  String _lastSubmittedQuery = '';

  void _onSearch() {
    FocusScope.of(context).unfocus(); // ẩn bàn phím khi submit
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _hasSearched = false;
          _lastSubmittedQuery = '';
        });
      }
      context.read<ProfileViewModel>().searchPatientsForDoctor('');
      return;
    }
    if (mounted) {
      setState(() {
        _hasSearched = true;
        _lastSubmittedQuery = query;
      });
    }
    context.read<ProfileViewModel>().searchPatientsForDoctor(query);
  }

  void _onQueryChanged(String rawValue) {
    final query = rawValue.trim();
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _hasSearched = false;
          _lastSubmittedQuery = '';
        });
      }
      context.read<ProfileViewModel>().searchPatientsForDoctor('');
      return;
    }

    if (mounted) {
      setState(() {
        _hasSearched = true;
      });
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_lastSubmittedQuery == query) return;
      _lastSubmittedQuery = query;
      context.read<ProfileViewModel>().searchPatientsForDoctor(query);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
          'Tìm kiếm bệnh nhân',
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
                    onChanged: _onQueryChanged,
                    onSubmitted: (_) => _onSearch(),
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
                  onPressed: _onSearch,
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
                    if (!_hasSearched) {
                      return const Center(
                        child: Text(
                          'Nhập CCCD/SĐT và nhấn Tìm để tìm bệnh nhân.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Không tìm thấy bệnh nhân.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      );
                    }
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
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE0E6FF),
                            backgroundImage: user.avatarUrl.isNotEmpty
                                ? NetworkImage(user.avatarUrl)
                                : null,
                            child: user.avatarUrl.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: Color(0xFF246BFF),
                                  )
                                : null,
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorPatientDetailPage(
                                  patientId: user.id,
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
