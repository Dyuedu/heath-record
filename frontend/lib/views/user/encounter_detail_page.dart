import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/diagnostic_model.dart';
import 'package:frontend/data/models/record/encounter_model.dart';

class EncounterDetailPage extends StatelessWidget {
  final String relativeName;
  final EncounterModel encounter;

  const EncounterDetailPage({
    super.key,
    required this.relativeName,
    required this.encounter,
  });

  @override
  Widget build(BuildContext context) {
    final diagnostics = encounter.diagnostics;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF246BFF)),
        title: const Text(
          'Chi tiết đợt khám',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildEncounterHeader(),
          const SizedBox(height: 14),
          Text(
            'Hồ sơ: $relativeName',
            style: const TextStyle(
              color: Color(0xFF4E5D78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (diagnostics.isEmpty)
            _buildEmptyDiagnostics()
          else
            ...diagnostics.map((e) => _buildDiagnosticCard(context, e)),
        ],
      ),
    );
  }

  Widget _buildEncounterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            encounter.title,
            style: const TextStyle(
              color: Color(0xFF1F2D3D),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _buildEncounterSubtitle(),
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          if ((encounter.note ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              encounter.note!.trim(),
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(BuildContext context, DiagnosticModel diagnostic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF246BFF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _safeText(diagnostic.category),
                  style: const TextStyle(
                    color: Color(0xFF246BFF),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(diagnostic.datetimeEnd),
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('ID', diagnostic.id?.toString()),
          _buildInfoRow('Tag chính', diagnostic.tag),
          _buildInfoRow('Bác sĩ', diagnostic.doctor),
          _buildInfoRow('Cơ sở y tế', diagnostic.hospitalName),
          _buildInfoRow('Nội dung', diagnostic.data),
          if (diagnostic.tagNames.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Tags',
              style: TextStyle(
                color: Color(0xFF1F2D3D),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: diagnostic.tagNames.map(_tagChip).toList(),
            ),
          ],
          if (diagnostic.attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Tệp đính kèm',
              style: TextStyle(
                color: Color(0xFF1F2D3D),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _buildAttachmentImages(context, diagnostic.attachmentUrls),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    final text = _safeText(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 12.5,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9E4FF)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF246BFF),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAttachmentImages(BuildContext context, List<String> urls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: urls.map((url) {
        return InkWell(
          onTap: () => _showImagePreview(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
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

  Future<void> _showImagePreview(BuildContext context, String url) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
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

  Widget _buildEmptyDiagnostics() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Chưa có bệnh án con (diagnostic records) cho đợt khám này.',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
      ),
    );
  }

  String _buildEncounterSubtitle() {
    final hospital = _safeText(encounter.hospitalName);
    return '${_formatDate(encounter.datetimeStart)} • $hospital';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa rõ thời gian';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _safeText(String? value) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? 'Không có' : trimmed;
  }
}
