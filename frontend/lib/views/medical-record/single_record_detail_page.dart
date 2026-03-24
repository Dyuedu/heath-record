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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header inside card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF246BFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Color(0xFF246BFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        encounter.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1F2D3D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildEncounterSubtitle(encounter),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((encounter.note ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSection(
                      title: 'Ghi chú',
                      child: Text(
                        encounter.note ?? '',
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF4A5568)),
                      ),
                    ),
                  ),
                if (encounter.tagNames.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSection(
                      title: 'Tags',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: encounter.tagNames.map(_tagChip).toList(),
                      ),
                    ),
                  ),
                  
                const Text(
                  'Chi tiết chẩn đoán',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F2D3D),
                  ),
                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(DiagnosticModel diagnostic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF246BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  diagnostic.category,
                  style: const TextStyle(
                    color: Color(0xFF246BFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (diagnostic.tag != null && diagnostic.tag!.isNotEmpty)
                Text(
                  '#${diagnostic.tag}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              const Spacer(),
              if (diagnostic.datetimeEnd != null)
                Text(
                  '${diagnostic.datetimeEnd!.day}/${diagnostic.datetimeEnd!.month}/${diagnostic.datetimeEnd!.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if ((diagnostic.data ?? '').isNotEmpty)
            Text(
              diagnostic.data!,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          if (diagnostic.doctor != null && diagnostic.doctor!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Bác sĩ: ${diagnostic.doctor}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4E5D78)),
              ),
            ),
          if (diagnostic.hospitalName != null &&
              diagnostic.hospitalName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Cơ sở y tế: ${diagnostic.hospitalName}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4E5D78)),
              ),
            ),
          if (diagnostic.tagNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: diagnostic.tagNames.map(_tagChip).toList(),
              ),
            ),
          if (diagnostic.attachmentUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildAttachmentImages(diagnostic.attachmentUrls),
            ),
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

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF246BFF),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
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

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(
          color: Color(0xFF246BFF),
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
