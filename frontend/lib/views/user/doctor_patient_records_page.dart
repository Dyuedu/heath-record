import 'package:flutter/material.dart';
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
            return const Center(
              child: Text(
                'Không tải được dữ liệu bệnh án.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!;

          if (data.records.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.patientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2A44),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Người dùng này chưa có bệnh án.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.records.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    data.patientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2A44),
                    ),
                  ),
                );
              }

              final item = data.records[index - 1];
              return _buildRecordCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(_EncounterWithOwner item) {
    final record = item.encounter;
    final date = record.datetimeEnd ?? record.datetimeStart;
    final dateText = date == null
        ? 'Không rõ thời gian'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E6FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.title.isEmpty ? 'Không có tiêu đề' : record.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: Color(0xFF1F2A44),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ngày khám: $dateText',
            style: const TextStyle(color: Color(0xFF5F6368), fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Hồ sơ: ${item.ownerName} (${item.relationship.isEmpty ? 'N/A' : item.relationship})',
            style: const TextStyle(color: Color(0xFF5F6368), fontSize: 12.5),
          ),
          if ((record.note ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.note!.trim(),
              style: const TextStyle(color: Color(0xFF1F2A44), fontSize: 13),
            ),
          ],
        ],
      ),
    );
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
