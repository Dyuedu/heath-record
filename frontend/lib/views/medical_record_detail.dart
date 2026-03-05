// medical_record_detail.dart
import 'package:flutter/material.dart';
import 'medical_records.dart';

class MedicalRecordDetail extends StatelessWidget {
  final MedicalRecord record;

  const MedicalRecordDetail({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final fields = [
      {'label': 'Tiêu đề', 'value': record.title},
      {'label': 'Mã y tế', 'value': record.medicalCode},
      {'label': 'Tên khách hàng', 'value': record.patientName},
      {'label': 'Loại hồ sơ', 'value': record.recordType},
      {'label': 'Địa điểm', 'value': record.location},
      {'label': 'Ngày khám bệnh', 'value': record.visitDate},
      {'label': 'Bác sĩ', 'value': record.doctor},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Status bar and header
          Container(
            color: const Color(0xFF4DD9D0),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Status bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('9:41', style: TextStyle(color: Colors.black, fontSize: 14)),
                        Row(
                          children: const [
                            Text('●●●', style: TextStyle(color: Colors.black, fontSize: 12)),
                            SizedBox(width: 4),
                            Text('▲', style: TextStyle(color: Colors.black, fontSize: 12)),
                            SizedBox(width: 4),
                            Text('■', style: TextStyle(color: Colors.black, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: fields.length + 3, // +3 for tags, description, file sections
              itemBuilder: (context, index) {
                if (index < fields.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FieldCard(
                      label: fields[index]['label']!,
                      value: fields[index]['value']!,
                    ),
                  );
                } else if (index == fields.length) {
                  // Tags section
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tag',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: record.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A9EDB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (index == fields.length + 1) {
                  // Description section
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mô tả chi tiết',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 64),
                            child: Text(
                              record.description.isEmpty ? '' : record.description,
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // File section
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'File',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.insert_drive_file, size: 28, color: Colors.blue[500]),
                              const SizedBox(width: 8),
                              Text(
                                record.file,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FieldCard extends StatelessWidget {
  final String label;
  final String value;

  const FieldCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}