import 'package:flutter/material.dart';
import 'package:frontend/views/medical-record/create_record_page.dart';
import 'package:frontend/widgets/bottom_nav.dart';

class MedicalRecordPage extends StatefulWidget {
  const MedicalRecordPage({super.key});

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  String selectedRelative = "Me"; // Quản lý người thân

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Medical Records", style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
      ),
      body: Column(
        children: [
          // Chọn người thân (Relative Selector)
          _buildRelativeSelector(),
          
          // Danh sách Hồ sơ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => _buildRecordCard(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF246BFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRecordPage())),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildRelativeSelector() {
    List<String> relatives = ["Me", "Mom", "Dad", "Brother"];
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: relatives.map((name) => GestureDetector(
          onTap: () => setState(() => selectedRelative = name),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: selectedRelative == name ? const Color(0xFF246BFF) : const Color(0xFFDDE3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(name, style: TextStyle(color: selectedRelative == name ? Colors.white : const Color(0xFF246BFF)))),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildRecordCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Blood Test Result", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF246BFF), fontSize: 16)),
              const Icon(Icons.star, color: Color(0xFF246BFF), size: 20), // Quan trọng
            ],
          ),
          const SizedBox(height: 8),
          const Text("Diagnosis: Normal / 20 Jan 2026", style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 10),
          // Tags Display
          Wrap(
            spacing: 8,
            children: ["Lab Test", "Blood", "Urgent"].map((tag) => _miniTag(tag)).toList(),
          )
        ],
      ),
    );
  }

  Widget _miniTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Text("#$text", style: const TextStyle(color: Color(0xFF246BFF), fontSize: 10)),
  );
}