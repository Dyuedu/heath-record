import 'package:flutter/material.dart';
import 'package:frontend/views/staff_record_management/add_edit_record_screen.dart';
import 'package:frontend/views/staff_record_management/models.dart';

class RecordDetailScreen extends StatelessWidget {
  final MedicalRecord record;

  const RecordDetailScreen({required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết hồ sơ"),
        backgroundColor: const Color(0xFF6EC6C1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedRecord = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditRecordScreen(record: record),
                ),
              );

              if (updatedRecord != null) {
                Navigator.pop(context, updatedRecord);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _info("Bệnh nhân", record.patientName),
            _info("Mã bệnh nhân", record.patientCode),
            _info("Tiêu đề", record.title),
            _info("Bác sĩ", record.doctor),
            _info("Ngày khám", record.date.toString()),
            _info("Mô tả", record.description),

            const SizedBox(height: 20),
            const Text(
              "Hình ảnh đính kèm",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildImageGallery(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    if (record.imagePaths.isEmpty) {
      return const Text("Chưa có hình ảnh");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: record.imagePaths.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final imageUrl = record.imagePaths[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _ImagePreviewScreen(imageUrl: imageUrl),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const _ImagePreviewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.asset(imageUrl),
        ),
      ),
    );
  }
}