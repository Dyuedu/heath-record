import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/diagnostic_model.dart';
import 'package:frontend/data/models/record/encounter_model.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:provider/provider.dart';

class SingleRecordDetailPage extends StatefulWidget {
  final String recordId;

  const SingleRecordDetailPage({super.key, required this.recordId});

  @override
  State<SingleRecordDetailPage> createState() => _SingleRecordDetailPageState();
}

class _SingleRecordDetailPageState extends State<SingleRecordDetailPage> {
  late Future<EncounterModel?> _futureRecord;

  @override
  void initState() {
    super.initState();
    _futureRecord = _fetchRecord();
  }

  Future<EncounterModel?> _fetchRecord() async {
    final repo = context.read<RecordRepository>();
    return await repo.getRecordById(widget.recordId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Chi tiết bệnh án',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF246BFF)),
      ),
      body: FutureBuilder<EncounterModel?>(
        future: _futureRecord,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildLoadFailedState();
          }

          final encounter = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildEncounterCard(encounter),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadFailedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Không thể tải dữ liệu bệnh án.\nBệnh án có thể không tồn tại hoặc bạn không có quyền xem.',
              style: TextStyle(color: Colors.redAccent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterCard(EncounterModel encounter) {
    final diagnostics = encounter.diagnostics;

    String examType = 'Tái khám';
    String doctorName = 'Không có thông tin';
    if (diagnostics.isNotEmpty) {
      if (diagnostics.first.type != null) {
        switch (diagnostics.first.type) {
          case 'INITIAL': examType = 'Khám mới'; break;
          case 'FOLLOW_UP': examType = 'Tái khám'; break;
          case 'ROUTINE_BACKUP': examType = 'Khám định kỳ'; break;
        }
      }
      if (diagnostics.first.doctor != null && diagnostics.first.doctor!.isNotEmpty) {
        doctorName = diagnostics.first.doctor!;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(Icons.person_outline, 'BÁC SĨ CHẨN ĐOÁN'),
          const SizedBox(height: 8),
          _buildTextValue(doctorName),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel(Icons.calendar_today_outlined, 'NGÀY KHÁM'),
                    const SizedBox(height: 8),
                    _buildTextValue(_buildEncounterSubtitle(encounter)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel(Icons.access_time_outlined, 'LOẠI KHÁM'),
                    const SizedBox(height: 8),
                    _buildTextValue(examType),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          _buildSectionLabel(Icons.description_outlined, 'TIÊU ĐỀ HỒ SƠ BỆNH ÁN'),
          const SizedBox(height: 8),
          _buildTextValue(encounter.title),
          
          if ((encounter.hospitalName ?? '').isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionLabel(Icons.domain_outlined, 'BỆNH VIỆN / CƠ SỞ Y TẾ'),
            const SizedBox(height: 8),
            _buildTextValue(encounter.hospitalName!),
          ],

          if ((encounter.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionLabel(Icons.assignment_outlined, 'GHI CHÚ BÁC SĨ'),
            const SizedBox(height: 8),
            _buildTextValue(encounter.note!),
          ],

          if (encounter.tagNames.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionLabel(Icons.local_offer_outlined, 'NHÃN PHÂN LOẠI CHUNG (TAGS)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: encounter.tagNames.map(_tagChip).toList(),
            ),
          ],
          
          const SizedBox(height: 32),
          _buildSectionLabel(Icons.medical_information_outlined, 'DANH MỤC CHẨN ĐOÁN'),
          const SizedBox(height: 12),
          
          if (diagnostics.isEmpty)
            _buildEmptyDiagnostics()
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: diagnostics.map(_buildDiagnosticCard).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(DiagnosticModel diagnostic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(Icons.label_important_outline, 'TÊN CHẨN ĐOÁN'),
          const SizedBox(height: 8),
          _buildTextValue(diagnostic.category),
          
          if (diagnostic.tagNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionLabel(Icons.local_offer_outlined, 'NHÃN PHÂN LOẠI (TAGS)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: diagnostic.tagNames.map(_tagChip).toList(),
            ),
          ],
          
          if ((diagnostic.data ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionLabel(Icons.notes_outlined, 'GHI CHÚ CHẨN ĐOÁN'),
            const SizedBox(height: 8),
            _buildTextValue(diagnostic.data!),
          ],

          if (diagnostic.attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionLabel(Icons.attach_file_outlined, 'TỆP ĐÍNH KÈM CHẨN ĐOÁN'),
            const SizedBox(height: 8),
            _buildAttachmentImages(diagnostic.attachmentUrls),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentImages(List<String> urls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: urls.map((url) {
        return InkWell(
          onTap: () => _showImagePreview(url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 92,
                height: 92,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showImagePreview(String url) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 220,
                    child: Center(
                      child: Icon(Icons.broken_image, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextValue(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildEmptyDiagnostics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chưa có chẩn đoán chi tiết cho lần khám này.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Color> _tagColors = [
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // amber
    Color(0xFF3B82F6), // blue
    Color(0xFFEF4444), // red
    Color(0xFF8B5CF6), // purple
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFFF97316), // orange
    Color(0xFF6366F1), // indigo
    Color(0xFF14B8A6), // teal
  ];

  static final Map<String, Color> _assignedTagColors = {};

  Color _getColorForTag(String tag) {
    if (_assignedTagColors.containsKey(tag)) {
      return _assignedTagColors[tag]!;
    }
    final color = _tagColors[tag.hashCode.abs() % _tagColors.length];
    _assignedTagColors[tag] = color;
    return color;
  }

  Widget _tagChip(String text) {
    final color = _getColorForTag(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$text',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _buildEncounterSubtitle(EncounterModel encounter) {
    final time = encounter.datetimeEnd ?? encounter.datetimeStart;
    return time == null
        ? 'Không rõ ngày khám'
        : '${time.day}/${time.month}/${time.year}';
  }
}
