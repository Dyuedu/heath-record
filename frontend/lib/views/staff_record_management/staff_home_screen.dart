import 'package:flutter/material.dart';
import 'package:frontend/views/staff_record_management/add_edit_record_screen.dart';
import 'package:frontend/views/staff_record_management/mock_data.dart';
import 'package:frontend/views/staff_record_management/models.dart';
import 'package:frontend/views/staff_record_management/record_detail_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  List<MedicalRecord> records = List.from(mockRecords);
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filtered = records.where((r) {
      return r.patientName
          .toLowerCase()
          .contains(searchText.toLowerCase()) ||
          r.title
              .toLowerCase()
              .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EC6C1),
        elevation: 0,
        title: const Text("Hồ sơ mới nhập"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              // TODO: filter bottom sheet
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6EC6C1),
        child: const Icon(Icons.add),
        onPressed: () async {
          final newRecord = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditRecordScreen(),
            ),
          );

          if (newRecord != null) {
            setState(() {
              records.insert(0, newRecord);
            });
          }
        },
      ),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("Không có dữ liệu"))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = filtered[index];

                return Dismissible(
                  key: Key(record.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      records.remove(record);
                    });
                  },
                  child: _RecordCard(
                    record: record,
                    onTap: () async {
                      final updatedRecord = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordDetailScreen(record: record),
                        ),
                      );

                      if (updatedRecord != null) {
                        final index =
                        records.indexWhere((r) => r.id == updatedRecord.id);

                        if (index != -1) {
                          setState(() {
                            records[index] = updatedRecord;
                          });
                        }
                      }
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Tìm bệnh nhân hoặc tiêu đề...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback onTap;

  const _RecordCard({
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8EDAD5),
              Color(0xFF6EC6C1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.patientName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Text("Mã: ${record.patientCode}",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(record.title,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// class _RecordCard extends StatelessWidget {
//   final MedicalRecord record;
//
//   const _RecordCard({required this.record});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: Material(
//         borderRadius: BorderRadius.circular(16),
//         elevation: 3,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () async {
//             final updated = await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => RecordDetailScreen(
//                   record: record,
//                   onUpdate: (newRecord) {
//                     final index = records.indexWhere((r) => r.id == newRecord.id);
//                     setState(() {
//                       records[index] = newRecord;
//                     });
//                   },
//                 ),
//               ),
//             );
//           },
//           child: Ink(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   Color(0xFF8EDAD5),
//                   Color(0xFF6EC6C1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment:
//                 CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     record.patientName,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     "Mã: ${record.patientCode}",
//                     style: const TextStyle(
//                         color: Colors.white70),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     record.title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight:
//                       FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     children:
//                     record.tags.map((tag) {
//                       return Container(
//                         padding:
//                         const EdgeInsets
//                             .symmetric(
//                             horizontal: 12,
//                             vertical: 6),
//                         decoration:
//                         BoxDecoration(
//                           color: Colors.white,
//                           borderRadius:
//                           BorderRadius
//                               .circular(20),
//                         ),
//                         child: Text(
//                           tag,
//                           style:
//                           const TextStyle(
//                               fontSize: 12),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }