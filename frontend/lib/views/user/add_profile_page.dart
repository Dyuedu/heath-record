import 'package:flutter/material.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  String selectedGender = "Nam";
  String selectedRelation = "Khác";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thông tin cơ bản",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Picker
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt, size: 16, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input fields
                  _buildTextField(Icons.edit, "Họ tên đầy đủ *"),
                  _buildTextField(Icons.badge_outlined, "Tên thân mật"),
                  _buildTextField(Icons.cake_outlined, "Ngày sinh"),
                  _buildTextField(Icons.phone_iphone, "Số điện thoại *"),
                  _buildTextField(Icons.email_outlined, "Email"),

                  const SizedBox(height: 20),
                  const Text("Giới tính *", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildSelectBox("Nam", Icons.male, selectedGender == "Nam", (val) => setState(() => selectedGender = val))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSelectBox("Nữ", Icons.female, selectedGender == "Nữ", (val) => setState(() => selectedGender = val))),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text("Đây là hồ sơ của *", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ["Con", "Vợ", "Chồng", "Bố", "Mẹ", "Khác"].map((relation) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 56) / 3,
                        child: _buildSelectBox(relation, null, selectedRelation == relation, (val) => setState(() => selectedRelation = val)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          // Nút Hoàn tất cố định ở dưới
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA8DADC), // Màu xanh nhạt khi chưa valid hoặc màu theo ảnh
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("HOÀN TẤT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF26BC9B))),
        ),
      ),
    );
  }

  Widget _buildSelectBox(String label, IconData? icon, bool isActive, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF26BC9B).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? const Color(0xFF26BC9B) : Colors.transparent),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, size: 18, color: isActive ? const Color(0xFF26BC9B) : Colors.grey),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? const Color(0xFF26BC9B) : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (isActive)
              const Positioned(
                right: 4,
                top: 0,
                child: Icon(Icons.check_circle, size: 14, color: Color(0xFF26BC9B)),
              ),
          ],
        ),
      ),
    );
  }
}