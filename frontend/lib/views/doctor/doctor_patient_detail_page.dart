import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/encounter_model.dart';
import 'package:frontend/data/models/user/doctor_patient_detail_model.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/user/doctor_patient_records_page.dart';
import 'package:provider/provider.dart';

class DoctorPatientDetailPage extends StatefulWidget {
  final String patientId;

  const DoctorPatientDetailPage({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientDetailPage> createState() =>
      _DoctorPatientDetailPageState();
}

class _DoctorPatientDetailPageState extends State<DoctorPatientDetailPage> {
  bool _isLoading = true;
  DoctorPatientDetailModel? _detail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await context
          .read<ProfileViewModel>()
          .fetchDoctorPatientDetail(widget.patientId);

      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Lỗi khi tải chi tiết bệnh nhân.';
          _isLoading = false;
        });
      }
    }
  }

  int _calculateAge(String dob) {
    if (dob.isEmpty) return 0;
    try {
      final parts = dob.split('/');
      if (parts.length >= 3) {
        final year = int.parse(parts[2]);
        return DateTime.now().year - year;
      }
    } catch (_) {}
    return 0;
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Không rõ ngày';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _getDoctorName(EncounterModel encounter) {
    if (encounter.diagnostics.isNotEmpty) {
      final doc = encounter.diagnostics.first.doctor;
      if (doc != null && doc.isNotEmpty) return 'BS. $doc';
    }
    return 'Bác sĩ';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _detail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? 'Không tìm thấy thông tin bệnh nhân.',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final patient = _detail!.patient;
    final relatives = _detail!.relatives;
    final name = patient.fullName.isEmpty ? 'Không rõ tên' : patient.fullName;
    final age = _calculateAge(patient.dateOfBirth);
    final gender = patient.gender.isEmpty ? 'Không rõ' : patient.gender;

    final flatRecords = <EncounterModel>[];
    for (final relative in relatives) {
      flatRecords.addAll(relative.encounters);
    }
    flatRecords.sort((a, b) {
      final aTime = a.datetimeEnd ?? a.datetimeStart;
      final bTime = b.datetimeEnd ?? b.datetimeStart;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    final recentRecords = flatRecords.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Avatar & Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: patient.avatarUrl.isNotEmpty
                        ? NetworkImage(patient.avatarUrl)
                        : null,
                    backgroundColor: const Color(0xFFE0E6FF),
                    child: patient.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 40, color: Color(0xFF246BFF))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.bodyTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    age > 0 ? '$age tuổi • $gender' : gender,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.captionTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thông tin cá nhân
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.badge_outlined, 'Mã bệnh nhân', patient.identityNumber.isEmpty ? 'Chưa cập nhật' : patient.identityNumber, isHighlight: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE0E6FF)),
                  ),
                  _buildDetailRow(Icons.phone_outlined, 'Số điện thoại', patient.phoneNumber.isEmpty ? 'Chưa cập nhật' : patient.phoneNumber),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE0E6FF)),
                  ),
                  _buildDetailRow(Icons.cake_outlined, 'Ngày sinh', patient.dateOfBirth.isEmpty ? 'Chưa cập nhật' : patient.dateOfBirth),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE0E6FF)),
                  ),
                  _buildDetailRow(Icons.person_outline, 'Giới tính', patient.gender.isEmpty ? 'Không rõ' : patient.gender),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE0E6FF)),
                  ),
                  _buildDetailRow(Icons.bloodtype_outlined, 'Nhóm máu', (patient.bloodGroup ?? '').isNotEmpty ? patient.bloodGroup! : 'Không rõ'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE0E6FF)),
                  ),
                  _buildDetailRow(Icons.location_on_outlined, 'Địa chỉ', patient.address.isEmpty ? 'Chưa cập nhật' : patient.address),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    icon: Icons.history,
                    label: 'Lịch sử bệnh',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorPatientRecordsPage(
                            patientId: patient.id,
                            patientName: patient.fullName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    icon: Icons.add_circle_outline,
                    label: 'Tạo bệnh án',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chức năng Tạo bệnh án đang phát triển')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Medical Summary (Mock data based on design)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.show_chart, color: Color(0xFF246BFF)),
                    SizedBox(width: 8),
                    Text(
                      'Tóm tắt y tế',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bodyTextColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text('Cập nhật: 2 giờ trước', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMedicalBox(
              icon: Icons.error_outline,
              iconColor: Colors.red,
              title: 'DỊ ỨNG',
              content: (patient.allergy ?? '').isNotEmpty ? patient.allergy! : 'Không có',
              bgColor: Colors.red.shade50,
              borderColor: Colors.red.shade100,
            ),
            const SizedBox(height: 12),
            _buildMedicalBox(
              icon: Icons.timeline,
              iconColor: Colors.black87,
              title: 'BỆNH MÃN TÍNH',
              content: (patient.chronicDisease ?? '').isNotEmpty ? patient.chronicDisease! : 'Không có',
              bgColor: Colors.white,
              borderColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            _buildMedicalBox(
              icon: Icons.note_alt_outlined,
              iconColor: Colors.blue,
              title: 'GHI CHÚ LÂM SÀNG',
              content: (patient.clinicalNotes ?? '').isNotEmpty ? patient.clinicalNotes! : 'Không có',
              bgColor: Colors.blue.shade50,
              borderColor: Colors.blue.shade100,
            ),
            const SizedBox(height: 32),

            // Linked Relatives
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Người thân liên kết',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.bodyTextColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (relatives.any((r) => r.relationship.toLowerCase() != 'me'))
                    ...relatives.where((r) => r.relationship.toLowerCase() != 'me').map((rel) => _buildRelativeAvatar(rel.relativeName.isNotEmpty ? '${rel.relativeName}\n(${rel.relationship})' : rel.relationship, rel.avatarUrl)),
                  if (!relatives.any((r) => r.relationship.toLowerCase() != 'me'))
                    const Text('Chưa có người thân liên kết.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Mock Recent Records
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bệnh án gần đây',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bodyTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorPatientRecordsPage(
                          patientId: patient.id,
                          patientName: patient.fullName,
                        ),
                      ),
                    );
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentRecords.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Không có bệnh án gần đây.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ...recentRecords.map((record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRecentRecordCard(
                      _formatDate(record.datetimeEnd ?? record.datetimeStart),
                      '#${record.id ?? '?'}',
                      record.title.isEmpty ? 'Khám bệnh' : record.title,
                      _getDoctorName(record),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlight ? const Color(0xFF246BFF) : AppTheme.bodyTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF246BFF)),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppTheme.bodyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelativeAvatar(String label, String url, {bool isAdd = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isAdd ? Border.all(color: Colors.grey.shade300, width: 2) : null,
              color: isAdd ? Colors.white : const Color(0xFFF0F4FF),
            ),
            child: isAdd
                ? const Icon(Icons.add, color: Colors.grey)
                : (url.isNotEmpty
                    ? ClipOval(child: Image.network(url, fit: BoxFit.cover))
                    : const Icon(Icons.person, color: Color(0xFF246BFF))),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecordCard(String date, String id, String title, String doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFF246BFF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        id,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.bodyTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor,
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
