import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/diagnostic_model.dart';
import 'package:frontend/data/models/record/encounter_model.dart';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class DoctorPatientRecordsPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorPatientRecordsPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorPatientRecordsPage> createState() =>
      _DoctorPatientRecordsPageState();
}

class _DoctorPatientRecordsPageState extends State<DoctorPatientRecordsPage> {
  late Future<_PatientRecordsViewData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_PatientRecordsViewData?> _loadData() async {
    final vm = context.read<ProfileViewModel>();
    final detail = await vm.fetchDoctorPatientDetail(widget.patientId);
    if (detail == null) {
      return null;
    }

    final flatRecords = <_EncounterWithOwner>[];
    for (final relative in detail.relatives) {
      for (final record in relative.encounters) {
        flatRecords.add(
          _EncounterWithOwner(
            ownerName: _normalizeRelativeName(relative),
            relationship: relative.relationship,
            encounter: record,
          ),
        );
      }
    }

    flatRecords.sort((a, b) {
      final aTime = a.encounter.datetimeEnd ?? a.encounter.datetimeStart;
      final bTime = b.encounter.datetimeEnd ?? b.encounter.datetimeStart;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    return _PatientRecordsViewData(
      patientName: detail.patient.fullName.isEmpty
          ? widget.patientName
          : detail.patient.fullName,
      records: flatRecords,
    );
  }

  String _normalizeRelativeName(RelativeHistoryModel relative) {
    final name = relative.relativeName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    final relation = relative.relationship.trim();
    if (relation.toLowerCase() == 'me') {
      return 'Bản thân';
    }
    return relation.isEmpty ? 'Không rõ' : relation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Bệnh án người dùng',
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
      body: FutureBuilder<_PatientRecordsViewData?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildLoadFailedState(),
              ],
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildPatientHeader(data),
              const SizedBox(height: 16),
              if (data.records.isEmpty)
                _buildEmptyState()
              else
                ...data.records.map(_buildEncounterCard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPatientHeader(_PatientRecordsViewData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.patientName,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF1F2D3D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng số lần khám: ${data.records.length}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF4E5D78)),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterCard(_EncounterWithOwner item) {
    final encounter = item.encounter;
    final diagnostics = encounter.diagnostics;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
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
        title: Text(
          encounter.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1F2D3D),
          ),
        ),
        subtitle: Text(
          _buildEncounterSubtitle(encounter, item),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        children: [
          if ((encounter.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSection(
                title: 'Ghi chú',
                child: Text(
                  encounter.note ?? '',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ),
          if (encounter.tagNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSection(
                title: 'Tags',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: encounter.tagNames.map(_tagChip).toList(),
                ),
              ),
            ),
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

  Widget _buildLoadFailedState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          SizedBox(height: 12),
          Text(
            'Không thể tải dữ liệu hồ sơ. Vui lòng thử lại.',
            style: TextStyle(color: Colors.redAccent, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'Chưa có lần khám nào được lưu lại.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
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

  String _buildEncounterSubtitle(EncounterModel encounter, _EncounterWithOwner item) {
    final time = encounter.datetimeEnd ?? encounter.datetimeStart;
    final dateText = time == null
        ? 'Không rõ ngày khám'
        : '${time.day}/${time.month}/${time.year}';
    final relation = item.relationship.isEmpty ? 'N/A' : item.relationship;
    return '$dateText • ${item.ownerName} ($relation)';
  }
}

class _EncounterWithOwner {
  final String ownerName;
  final String relationship;
  final EncounterModel encounter;

  const _EncounterWithOwner({
    required this.ownerName,
    required this.relationship,
    required this.encounter,
  });
}

class _PatientRecordsViewData {
  final String patientName;
  final List<_EncounterWithOwner> records;

  const _PatientRecordsViewData({
    required this.patientName,
    required this.records,
  });
}
