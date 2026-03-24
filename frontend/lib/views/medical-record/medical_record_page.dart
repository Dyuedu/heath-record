import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';
import 'package:frontend/viewmodels/record_view_model.dart';
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
    // Khởi tạo dữ liệu khi vào trang
    Future.microtask(() => context.read<RecordViewModel>().initData());
  }

  /// Hàm xử lý khi người dùng kéo màn hình xuống để Reload
  Future<void> _handleRefresh() async {
    // Nạp lại toàn bộ dữ liệu từ Server
    await context.read<RecordViewModel>().initData();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecordViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          "Medical Records",
          style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Bọc toàn bộ vùng cuộn bằng RefreshIndicator
      body: RefreshIndicator(
        color: const Color(0xFF246BFF),
        backgroundColor: Colors.white,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          // Luôn cho phép cuộn để hiện biểu tượng Loading
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Phần Selector người thân (Dùng SliverToBoxAdapter để chứa Widget thường)
            SliverToBoxAdapter(
              child: _buildRelativeSelector(vm),
            ),

            // 2. Phần nội dung chính (Records)
            if (vm.isLoading && vm.records.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.records.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRecordCard(vm.records[index]),
                    childCount: vm.records.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildRelativeSelector(RecordViewModel vm) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 12),
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
                border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFDDE3FF)),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(color: const Color(0xFF246BFF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Center(
                child: Text(
                  rel.name,
                  style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF246BFF), fontWeight: FontWeight.bold),
                ),
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _getTypeColor(record.type).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(_getTypeIcon(record.type), color: _getTypeColor(record.type)),
        ),
        title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(
          "${record.type} • ${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Icon(
          record.isImportant ? Icons.bookmark : Icons.bookmark_border,
          color: record.isImportant ? const Color(0xFF246BFF) : Colors.grey,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF246BFF))),
                const SizedBox(height: 6),
                Text(
                  record.notes.isEmpty ? "Không có ghi chú thêm." : record.notes,
                  style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                ),
                if (record.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: record.tags.map((tag) => _miniTag(tag)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Chưa có hồ sơ bệnh án", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text("Vuốt xuống để tải lại dữ liệu", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // --- HELPERS ---

  IconData _getTypeIcon(String type) {
    if (type == 'Test') return Icons.biotech_rounded;
    if (type == 'Prescription') return Icons.medication_rounded;
    return Icons.assignment_rounded;
  }

  Color _getTypeColor(String type) {
    if (type == 'Test') return Colors.purple;
    if (type == 'Prescription') return Colors.orange;
    return const Color(0xFF246BFF);
  }

  Widget _miniTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(8)),
    child: Text("#$text", style: const TextStyle(color: Color(0xFF246BFF), fontSize: 11, fontWeight: FontWeight.bold)),
  );
}