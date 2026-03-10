import 'package:flutter/material.dart';
import 'package:frontend/data/models/patient/patient_model.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';

class RecordDetailPage extends StatelessWidget {
  final PatientModel patient;
  final MedicalRecordModel record;

  const RecordDetailPage({super.key, required this.patient, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text(
          'Chi tiết bệnh án',
          style: TextStyle(color: Color(0xFF1F2A44), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1F2A44)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PatientSummary(patient: patient),
            const SizedBox(height: 24),
            _RecordSummary(record: record),
          ],
        ),
      ),
    );
  }
}

class _PatientSummary extends StatelessWidget {
  final PatientModel patient;
  const _PatientSummary({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF246BFF),
            child: Text(
              patient.fullName.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: const TextStyle(color: Color(0xFF1F2A44), fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text('SĐT: ${patient.phoneNumber}', style: const TextStyle(color: Colors.black54)),
                if (patient.email.isNotEmpty)
                  Text('Email: ${patient.email}', style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordSummary extends StatelessWidget {
  final MedicalRecordModel record;
  const _RecordSummary({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconByType(record.type),
                color: _colorByType(record.type),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  record.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2A44)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ngày tạo: ${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text('Loại: ${record.type}', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          if (record.notes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2A44))),
                const SizedBox(height: 6),
                Text(record.notes, style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 12),
              ],
            ),
          if (record.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: record.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.w600),
                        ),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 16),
          // if (record.attachments.isNotEmpty)
          //   Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text('Tệp đính kèm', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2A44))),
          //       const SizedBox(height: 10),
          //       ...record.attachments.map(
          //         (url) => Container(
          //           width: double.infinity,
          //           margin: const EdgeInsets.only(bottom: 8),
          //           padding: const EdgeInsets.all(12),
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(14),
          //             color: const Color(0xFFF2F5FF),
          //           ),
          //           child: Row(
          //             children: [
          //               const Icon(Icons.insert_drive_file, color: Color(0xFF246BFF)),
          //               const SizedBox(width: 10),
          //               Expanded(
          //                 child: Text(
          //                   url,
          //                   style: const TextStyle(color: Color(0xFF1F2A44)),
          //                   overflow: TextOverflow.ellipsis,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
        
        ],
      ),
    );
  }

  IconData _iconByType(String type) {
    switch (type) {
      case 'Test':
        return Icons.science_outlined;
      case 'Prescription':
        return Icons.medication_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  Color _colorByType(String type) {
    switch (type) {
      case 'Test':
        return const Color(0xFF9B51E0);
      case 'Prescription':
        return const Color(0xFFF2994A);
      default:
        return const Color(0xFF246BFF);
    }
  }
}
