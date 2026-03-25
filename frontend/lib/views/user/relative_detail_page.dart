import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/encounter_model.dart';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/relative_detail_viewmodel.dart';

class RelativeDetailPage extends StatefulWidget {
  final String relativeName;
  final String profileId;

  const RelativeDetailPage({
    super.key,
    required this.relativeName,
    required this.profileId,
  });

  @override
  State<RelativeDetailPage> createState() => _RelativeDetailPageState();
}

class _RelativeDetailPageState extends State<RelativeDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeDetailViewModel>().loadHistory(widget.profileId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelativeDetailViewModel>();
    final bool isActiveProfile = vm.activeProfileId == widget.profileId;
    final RelativeHistoryModel? history = isActiveProfile ? vm.history : null;

    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea bọc quanh body để tránh Notch/Bottom Bar
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context),
            _buildFilterBar(),
            Expanded(
              child: vm.isLoading && history == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => vm.refresh(widget.profileId),
                      child: _buildContent(history),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Thay AppBar mặc định bằng Custom Widget để kiểm soát tốt hơn trong SafeArea
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(child: _buildSearchBar()),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Tìm theo chẩn đoán, bác sĩ...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip("Tất cả", isSelected: true),
          const SizedBox(width: 8),
          _buildFilterChip("Nội khoa"),
          const SizedBox(width: 8),
          _buildFilterChip("Ngoại khoa"),
          const SizedBox(width: 16),
          const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF246BFF)),
          const SizedBox(width: 6),
          const Text("Gần đây", style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF246BFF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildContent(RelativeHistoryModel? history) {
    // Dữ liệu mẫu (Fake data)
    final encounters = [
      EncounterModel(
        title: "Viêm họng cấp, sốt siêu vi nhẹ. Cần theo dõi nhiệt độ thường xuyên.",
        datetimeStart: DateTime(2023, 8, 12),
        hospitalName: "Nội tổng quát", id: null, tag: '', note: '', datetimeEnd: null, tagNames: [], diagnostics: [],
      ),
      EncounterModel(
        title: "Viêm da cơ địa dị ứng thời tiết. Tình trạng ổn định.",
        datetimeStart: DateTime(2023, 5, 20),
        hospitalName: "Da liễu", id: null, tag: '', note: '', datetimeEnd: null, tagNames: [], diagnostics: [],
      ),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildPatientHeader(history),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TIẾN TRÌNH ĐIỀU TRỊ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4A4A4A), letterSpacing: 0.5),
            ),
            Text(
              "${encounters.length} bệnh án đã lưu",
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...encounters.map((e) => _buildEncounterCard(e)),
      ],
    );
  }

  Widget _buildPatientHeader(RelativeHistoryModel? history) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=32"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Trần Thị Hoa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1F2D3D))),
                const SizedBox(height: 2),
                const Text("ID: BN-100293", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                _buildBloodGroupBadge("NHÓM A+"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFCCF9E1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Color(0xFF00BD6B), fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildEncounterCard(EncounterModel encounter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${encounter.datetimeStart?.day} THÁNG 0${encounter.datetimeStart?.month}, ${encounter.datetimeStart?.year}",
                style: const TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(encounter.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.4, color: Color(0xFF2D3238))),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildInfoChip(Icons.person_outline, "BS. Nguyễn Văn An"),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.medical_services_outlined, encounter.hospitalName ?? "Nội khoa"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag("Tái khám"),
              const SizedBox(width: 8),
              _buildTag("Nội khoa"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w500)),
    );
  }
}