import 'dart:io'; // Thêm để dùng file ảnh local
import 'package:flutter/material.dart';
import 'package:frontend/data/models/profile_model.dart';
import 'package:image_picker/image_picker.dart'; // Thêm thư viện


class ProfileFormScreen extends StatefulWidget {
  final bool isEdit;
  final ProfileModel? profile;

  const ProfileFormScreen({super.key, required this.isEdit, this.profile});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  String? _selectedGender;
  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  // Biến lưu trữ ảnh vừa chọn
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.profile?.gender ?? 'Nam';
  }

  // Hàm xử lý chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // Mở thư viện ảnh
      maxWidth: 500, // Tối ưu kích thước để upload nhanh hơn
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF76D7C4),
        elevation: 0,
        title: Text(widget.isEdit ? 'Chỉnh sửa hồ sơ' : 'Thêm hồ sơ mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- KHU VỰC TẢI ẢNH ĐẠI DIỆN ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[200],
                      // Ưu tiên hiển thị ảnh vừa chọn, sau đó đến ảnh từ server, cuối cùng là icon mặc định
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : (widget.profile?.avatarUrl != null
                          ? NetworkImage(widget.profile!.avatarUrl!)
                          : null),
                      child: (_imageFile == null && widget.profile?.avatarUrl == null)
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  // Nút bấm chọn ảnh
                  GestureDetector(
                    onTap: _pickImage,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- CÁC Ô NHẬP LIỆU (Giữ nguyên như bản trước) ---
            _buildInput(Icons.qr_code, 'Mã y tế', widget.profile?.medicalCode ?? ''),
            _buildInput(Icons.person_outline, 'Họ tên', widget.profile?.fullName ?? ''),

            // Dropdown Giới tính
            _buildDropdownInput(Icons.wc, 'Giới tính'),

            _buildInput(Icons.phone, 'Số điện thoại', widget.profile?.phoneNumber ?? ''),
            _buildInput(Icons.location_on_outlined, 'Địa chỉ', widget.profile?.address ?? ''),

            const SizedBox(height: 30),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Sau này bạn sẽ dùng Dio để upload _imageFile lên backend tại đây
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81E1D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Lưu hồ sơ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildInput và _buildDropdownInput giữ nguyên như file tôi gửi trước đó...
  // (Tôi không viết lại để tránh làm loãng code, bạn cứ giữ nguyên nhé)
  Widget _buildInput(IconData icon, String label, String initialValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownInput(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: InputBorder.none,
        ),
        items: _genderOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (val) => setState(() => _selectedGender = val),
      ),
    );
  }
}