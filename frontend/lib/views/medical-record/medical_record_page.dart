import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';
import 'package:frontend/viewmodels/record_view_model.dart';
import 'package:frontend/views/medical-record/create_record_page.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

class MedicalRecordPage extends StatefulWidget {
  const MedicalRecordPage({super.key});
  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  @override
  void initState() {
    super.initState();
    // Gọi nạp dữ liệu ngay khi vào trang
    Future.microtask(() => context.read<RecordViewModel>().initData());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecordViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Nền nhạt sang trọng
      appBar: AppBar(
        title: const Text("Medical Records", style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        centerTitle: true, backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildRelativeSelector(vm),
          Expanded(
            child: vm.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : vm.records.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.records.length,
                    itemBuilder: (context, index) => _buildRecordCard(vm.records[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRecordPage())),
        backgroundColor: const Color(0xFF246BFF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Record", style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildRelativeSelector(RecordViewModel vm) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: vm.relatives.length,
        itemBuilder: (context, index) {
          final rel = vm.relatives[index];
          final isSelected = vm.selectedRelativeId == rel.id.toString();
          return GestureDetector(
            onTap: () => vm.fetchRecords(rel.id.toString()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF246BFF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected) BoxShadow(color: const Color(0xFF246BFF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                ],
                border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFDDE3FF)),
              ),
              child: Center(
                child: Text(rel.name, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF246BFF), fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecordModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTypeColor(record.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(record.type),
            color: _getTypeColor(record.type),
          ),
        ),
        title: Text(
          record.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          "${record.type} • ${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}",
          style: const TextStyle(fontSize: 12),
        ),
        trailing: record.isImportant 
            ? const Icon(Icons.bookmark, color: Color(0xFF246BFF)) 
            : const Icon(Icons.bookmark_border, color: Colors.grey),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  record.notes.isEmpty ? "No additional notes provided." : record.notes,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: record.tags.map((tag) => _miniTag(tag)).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Hàm hỗ trợ hiển thị Icon theo loại bệnh án
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Test': return Icons.biotech_outlined;
      case 'Prescription': return Icons.medication_outlined;
      default: return Icons.assignment_outlined;
    }
  }

  // Hàm hỗ trợ hiển thị Màu theo loại bệnh án
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Test': return Colors.purple;
      case 'Prescription': return Colors.orange;
      default: return const Color(0xFF246BFF);
    }
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No medical records found", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _miniTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(8)),
    child: Text("#$text", style: const TextStyle(color: Color(0xFF246BFF), fontSize: 11, fontWeight: FontWeight.bold)),
  );
}