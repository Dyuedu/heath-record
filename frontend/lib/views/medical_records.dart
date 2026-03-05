// medical_records.dart
import 'package:flutter/material.dart';

import 'filter_modal.dart';
import 'medical_record_detail.dart';

class MedicalRecord {
  final String id;
  final String date;
  final String hospital;
  final String recordType;
  final List<String> tags;
  final bool starred;
  final String title;
  final String medicalCode;
  final String patientName;
  final String location;
  final String visitDate;
  final String doctor;
  final String description;
  final String file;

  MedicalRecord({
    required this.id,
    required this.date,
    required this.hospital,
    required this.recordType,
    required this.tags,
    required this.starred,
    required this.title,
    required this.medicalCode,
    required this.patientName,
    required this.location,
    required this.visitDate,
    required this.doctor,
    required this.description,
    required this.file,
  });
}

// Fake data
final List<MedicalRecord> sampleRecords = [
  MedicalRecord(
    id: "1",
    date: "Monday, 27 March 2023",
    hospital: "Vinmec International Hospital",
    recordType: "Lab Results",
    tags: ["blood-test", "urinalysis", "imaging", "cholesterol"],
    starred: true,
    title: "Khám bệnh tâm thần",
    medicalCode: "0123456",
    patientName: "Phan Vũ Công Hưng",
    location: "Vinmec International Hospital",
    visitDate: "01/ 01/ 2026",
    doctor: "Vũ Trường Giang",
    description: "",
    file: "blood-test.pdf",
  ),
  MedicalRecord(
    id: "2",
    date: "Monday, 27 March 2023",
    hospital: "Vinmec International Hospital",
    recordType: "Lab Results",
    tags: ["blood-test", "urinalysis", "imaging", "cholesterol"],
    starred: true,
    title: "Xét nghiệm máu định kỳ",
    medicalCode: "0123457",
    patientName: "Nguyễn Thị Lan",
    location: "Vinmec International Hospital",
    visitDate: "15/ 02/ 2026",
    doctor: "Trần Minh Tuấn",
    description: "",
    file: "lab-results.pdf",
  ),
  MedicalRecord(
    id: "3",
    date: "Tuesday, 14 February 2023",
    hospital: "Bệnh viện Bạch Mai",
    recordType: "Imaging",
    tags: ["imaging", "cholesterol"],
    starred: false,
    title: "Chụp X-quang ngực",
    medicalCode: "0234567",
    patientName: "Lê Văn Bình",
    location: "Bệnh viện Bạch Mai",
    visitDate: "14/ 02/ 2023",
    doctor: "Phạm Thị Hoa",
    description: "Kết quả bình thường",
    file: "xray.pdf",
  ),
];

final List<String> customers = [
  "Phan Vũ Công Hưng",
  "Nguyễn Thị Lan",
  "Lê Văn Bình",
  "Trần Đức Nam",
];

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  String searchText = "";
  String selectedCustomer = "";
  bool showCustomerDropdown = false;

  List<MedicalRecord> get filteredRecords {
    return sampleRecords.where((record) {
      final matchCustomer = selectedCustomer.isEmpty ||
          record.patientName == selectedCustomer;
      final matchSearch = searchText.isEmpty ||
          record.title.toLowerCase().contains(searchText.toLowerCase()) ||
          record.recordType.toLowerCase().contains(searchText.toLowerCase()) ||
          record.tags.any((tag) => tag.contains(searchText.toLowerCase()));
      return matchCustomer && matchSearch;
    }).toList();
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Bệnh sử',
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

          // Search & Filter section
          Container(
            margin: const EdgeInsets.all(12),
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
                  'Chọn hồ sơ',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Customer selector
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showCustomerDropdown = !showCustomerDropdown;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 18, color: Colors.teal[300]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedCustomer.isEmpty ? 'Chọn khách hàng' : selectedCustomer,
                                  style: TextStyle(
                                    color: selectedCustomer.isEmpty ? Colors.grey[400] : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (showCustomerDropdown)
                      Positioned(
                        top: 48,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCustomer = '';
                                    showCustomerDropdown = false;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  child: const Text('Tất cả', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              ...customers.map((customer) => InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCustomer = customer;
                                    showCustomerDropdown = false;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  child: Text(customer, style: const TextStyle(fontSize: 14)),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Tìm kiếm',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                            Icon(Icons.search, size: 18, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _openFilterModal,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.filter_list, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Records list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecordCard(record: filteredRecords[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  final MedicalRecord record;

  const RecordCard({super.key, required this.record});

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalRecordDetail(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5ECEC8), Color(0xFFA8EDE9)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.date,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.hospital,
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.recordType,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (record.starred)
                Icon(
                  Icons.star,
                  size: 20,
                  color: Colors.amber[600],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: record.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _navigateToDetail(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}