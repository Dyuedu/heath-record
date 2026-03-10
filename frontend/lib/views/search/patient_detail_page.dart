import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/doctor_repository.dart';
import 'package:provider/provider.dart';
import '../../data/models/patient/patient_model.dart';
import '../../data/models/record/medical_record_model.dart';
import '../../viewmodels/patient_detail_viewmodel.dart';
import '../../views/medical-record/create_record_page.dart';

class PatientDetailPage extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientDetailViewModel(
        repository: context.read<DoctorRepository>(),
      )..loadPatientDetail(patient.id),
      child: _PatientDetailBody(initialPatient: patient),
    );
  }
}

class _PatientDetailBody extends StatelessWidget {
  final PatientModel initialPatient;
  const _PatientDetailBody({required this.initialPatient});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientDetailViewModel>();
    final currentPatient = vm.patient ?? initialPatient;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          // App Bar linh hoạt
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF8F9FD),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2A44), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(currentPatient.fullName,
                  style: const TextStyle(color: Color(0xFF1F2A44), fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
            ),
          ),

          // Nội dung chính
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PatientHeroCard(patient: currentPatient),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: "Hồ sơ liên quan"),
                  const SizedBox(height: 12),
                  _RelativeSelector(vm: vm),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionTitle(title: "Lịch sử bệnh án"),
                      if (vm.records.isNotEmpty)
                        Text("${vm.records.length} bản ghi", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Danh sách bệnh án (Sử dụng SliverList để tránh lỗi Overflow)
          vm.isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : vm.records.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyRecords())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _RecordCard(record: vm.records[index]),
                          ),
                          childCount: vm.records.length,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vm.selectedRelativeId == null
            ? null
            : () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRecordPage(relativeId: vm.selectedRelativeId!))),
        backgroundColor: vm.selectedRelativeId == null ? Colors.grey : const Color(0xFF246BFF),
        label: const Text("Thêm bệnh án", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_task, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- Các Widget thành phần đã được tối ưu ---

class _RecordCard extends StatelessWidget {
  final MedicalRecordModel record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(record.type);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, decoration: BoxDecoration(color: accentColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2A44)), overflow: TextOverflow.ellipsis)),
                        if (record.isImportant) const Icon(Icons.push_pin, size: 18, color: Color(0xFF246BFF)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year} • ${record.type}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (record.notes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(record.notes, style: const TextStyle(color: Color(0xFF4A5C8A), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccentColor(String type) {
    if (type == 'Test') return Colors.purple;
    if (type == 'Prescription') return Colors.orange;
    return const Color(0xFF246BFF);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Color(0xFF1F2A44), fontWeight: FontWeight.w800, fontSize: 18));
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 12),
        const Text("Chưa có hồ sơ bệnh án", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _PatientHeroCard extends StatelessWidget {
  final PatientModel patient;
  const _PatientHeroCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF246BFF), Color(0xFF6493FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF246BFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              patient.fullName.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  patient.phoneNumber,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelativeSelector extends StatelessWidget {
  final PatientDetailViewModel vm;
  const _RelativeSelector({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // Tăng chiều cao để chứa cả tên và quan hệ
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vm.relatives.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final relative = vm.relatives[index];
          final isSelected = vm.selectedRelativeId == relative.id;
          final isMe = relative.relationship?.toLowerCase() == 'me';

          return GestureDetector(
            onTap: () => vm.selectRelative(relative.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF246BFF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.black12,
                ),
                boxShadow: isSelected 
                  ? [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] 
                  : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMe ? Icons.person : Icons.group,
                    color: isSelected ? Colors.white : Colors.blue,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      isMe ? "Bản thân" : relative.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    isMe ? "Chính chủ" : (relative.relationship ?? ""),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}