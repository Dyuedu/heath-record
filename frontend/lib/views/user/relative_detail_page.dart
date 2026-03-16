import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/views/medical-record/create_record_page.dart';
import 'package:provider/provider.dart';

/// Trang hiển thị hồ sơ sức khoẻ (medical records) của một người thân.
class RelativeDetailPage extends StatefulWidget {
  final String relativeId;
  final String relativeName;

  const RelativeDetailPage({
    super.key,
    required this.relativeId,
    required this.relativeName,
  });

  @override
  State<RelativeDetailPage> createState() => _RelativeDetailPageState();
}

class _RelativeDetailPageState extends State<RelativeDetailPage> {
  List<MedicalRecordModel> _records = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<RecordRepository>();
      final records = await repo.getRecordsByRelative(widget.relativeId);
      if (!mounted) return;
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải hồ sơ sức khoẻ. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          widget.relativeName,
          style: const TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF246BFF),
        backgroundColor: Colors.white,
        onRefresh: _loadRecords,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateRecordPage(relativeId: widget.relativeId),
            ),
          );
          if (result == true) {
            _loadRecords();
          }
        },
        backgroundColor: const Color(0xFF246BFF),
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Thêm hồ sơ', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRecords,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF246BFF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_records.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có hồ sơ sức khoẻ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bấm nút + để thêm hồ sơ mới',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _records.length,
      itemBuilder: (context, index) => _buildRecordCard(_records[index]),
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTypeColor(record.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getTypeIcon(record.type),
              color: _getTypeColor(record.type)),
        ),
        title: Text(
          record.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${record.type} • ${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Icon(
          record.isImportant ? Icons.bookmark : Icons.bookmark_border,
          color: record.isImportant
              ? const Color(0xFF246BFF)
              : Colors.grey,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Ghi chú:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF246BFF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.notes.isEmpty
                      ? 'Không có ghi chú thêm.'
                      : record.notes,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (record.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        record.tags.map((tag) => _miniTag(tag)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

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
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '#$text',
          style: const TextStyle(
            color: Color(0xFF246BFF),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
