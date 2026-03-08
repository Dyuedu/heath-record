import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';

class MedicalTimelinePage extends StatefulWidget {
  const MedicalTimelinePage({super.key});

  @override
  State<MedicalTimelinePage> createState() => _MedicalTimelinePageState();
}

class _MedicalTimelinePageState extends State<MedicalTimelinePage> {
  String selectedRelative = "Me";
  List<String> activeFilters = ["All"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Medical History", style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF246BFF)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 1. Bộ chọn người thân (Relative Selector)
          _buildRelativeSelector(),
          
          // 2. Bộ lọc Tags nhanh (Quick Tag Filters)
          _buildTagFilters(),

          // 3. Danh sách Timeline
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4, // Số lượng bản ghi demo
              itemBuilder: (context, index) {
                // Dữ liệu demo cho timeline
                final records = [
                  {"date": "20 Jan 2026", "title": "General Checkup", "type": "Diagnosis", "tags": ["Routine", "Healthy"]},
                  {"date": "15 Jan 2026", "title": "Blood Test Result", "type": "Lab Test", "tags": ["Blood", "Urgent"]},
                  {"date": "10 Jan 2026", "title": "Prescription for Cough", "type": "Prescription", "tags": ["Flu", "Medication"]},
                  {"date": "05 Jan 2026", "title": "X-Ray Scan", "type": "Imaging", "tags": ["Bone", "Injury"]},
                ];
                return _buildTimelineItem(records[index]);
              },
            ),
          ),
        ],
      ),
      // Nút thêm record mới nổi bật
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF246BFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {}, // Chuyển sang trang Create Record
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  // --- Widget Components ---

  Widget _buildRelativeSelector() {
    List<String> relatives = ["Me", "Mom", "Dad", "Brother"];
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: relatives.map((name) => GestureDetector(
          onTap: () => setState(() => selectedRelative = name),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: selectedRelative == name ? const Color(0xFF246BFF) : const Color(0xFFDDE3FF),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(child: Text(name, style: TextStyle(color: selectedRelative == name ? Colors.white : const Color(0xFF246BFF)))),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTagFilters() {
    List<String> tags = ["All", "Heart", "Blood", "Lab Test", "Prescription", "Imaging"];
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: tags.map((tag) {
          bool isSelected = activeFilters.contains(tag);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(tag, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF246BFF), fontSize: 12)),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (tag == "All") {
                    activeFilters = ["All"];
                  } else {
                    activeFilters.remove("All");
                    if (selected) {
                      activeFilters.add(tag);
                    } else {
                      activeFilters.remove(tag);
                    }
                    if (activeFilters.isEmpty) activeFilters.add("All");
                  }
                });
              },
              backgroundColor: const Color(0xFFDDE3FF),
              selectedColor: const Color(0xFF246BFF),
              checkmarkColor: Colors.white,
              shape: StadiumBorder(side: BorderSide(color: isSelected ? const Color(0xFF246BFF) : Colors.transparent)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> record) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phần trục Timeline (Timeline Axis)
          Column(
            children: [
              Container(
                width: 12, height: 12,
                decoration: const BoxDecoration(color: Color(0xFF246BFF), shape: BoxShape.circle),
              ),
              Expanded(
                child: Container(width: 2, color: const Color(0xFFDDE3FF)),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Phần nội dung thẻ (Card Content)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(record["date"], style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      _typeBadge(record["type"]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(record["title"], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF246BFF), fontSize: 16)),
                  const SizedBox(height: 10),
                  // Hiển thị Tags trong thẻ
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (record["tags"] as List<String>).map((tag) => _miniTag(tag)).toList(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Text(type, style: const TextStyle(color: Color(0xFF246BFF), fontSize: 10, fontWeight: FontWeight.bold)),
  );

  Widget _miniTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Text("#$text", style: const TextStyle(color: Color(0xFF246BFF), fontSize: 10)),
  );
}