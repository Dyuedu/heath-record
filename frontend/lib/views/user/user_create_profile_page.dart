import 'package:flutter/material.dart';

class UserCreateProfilePage extends StatefulWidget {
  const UserCreateProfilePage({super.key});

  @override
  State<UserCreateProfilePage> createState() => _UserCreateProfilePage();
}

class _UserCreateProfilePage extends State<UserCreateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = 'Nam';

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF246BFF); // Xanh dương chủ đạo

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2A44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thông tin cơ bản",
          style: TextStyle(color: Color(0xFF1F2A44), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vui lòng nhập chính xác thông tin cá nhân",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Họ và tên
            _buildInputField(
              controller: _nameController,
              label: "Họ và tên",
              hint: "Nhập họ tên đầy đủ",
              icon: Icons.edit_outlined,
            ),
            const SizedBox(height: 20),

            // Ngày sinh
            _buildInputField(
              controller: _dobController,
              label: "Ngày sinh",
              hint: "07/01/2004",
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () {
                // Logic chọn ngày sinh ở đây
              },
            ),
            const SizedBox(height: 20),

            // Số điện thoại
            _buildInputField(
              controller: _phoneController,
              label: "Số điện thoại",
              hint: "0382458534",
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // Giới tính
            const Text(
              "Giới tính*",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2A44)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _genderButton("Nam", Icons.male, _selectedGender == "Nam", primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _genderButton("Nữ", Icons.female, _selectedGender == "Nữ", primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Nút Hoàn tất
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Logic lưu profile và tạo quan hệ 'Me' trong DB
                },
                child: const Text(
                  "HOÀN TẤT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF246BFF)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEEEEEE))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF246BFF))),
          ),
        ),
      ],
    );
  }

  Widget _genderButton(String label, IconData icon, bool isSelected, Color primary) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primary : const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}