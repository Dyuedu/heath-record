import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/models/record/add_relative_request.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nicknameCtrl = TextEditingController();
  final TextEditingController _identityCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  File? _avatarFile;

  String selectedGender = "Nam";
  String selectedRelation = "Khác";
  DateTime? _selectedDob;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _identityCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _nicknameCtrl.text.trim().isNotEmpty &&
      _identityCtrl.text.trim().isNotEmpty &&
      _dobCtrl.text.trim().isNotEmpty &&
      selectedGender.isNotEmpty &&
      selectedRelation.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final isSubmitting = viewModel.isAddLoading;

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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : null,
                          child: _avatarFile == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    icon: Icons.edit,
                    hint: "Họ tên đầy đủ *",
                    controller: _nameCtrl,
                  ),
                  _buildTextField(
                    icon: Icons.badge_outlined,
                    hint: "Tên thân mật *",
                    controller: _nicknameCtrl,
                  ),
                  _buildTextField(
                    icon: Icons.credit_card,
                    hint: "Số CCCD/CMND *",
                    controller: _identityCtrl,
                  ),
                  _buildTextField(
                    icon: Icons.cake_outlined,
                    hint: "Ngày sinh *",
                    controller: _dobCtrl,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    onTap: _pickDob,
                  ),
                  _buildTextField(
                    icon: Icons.phone_iphone,
                    hint: "Số điện thoại",
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Giới tính *",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectBox(
                          "Nam",
                          Icons.male,
                          selectedGender == "Nam",
                          (val) => setState(() => selectedGender = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectBox(
                          "Nữ",
                          Icons.female,
                          selectedGender == "Nữ",
                          (val) => setState(() => selectedGender = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Đây là hồ sơ của *",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ["Con", "Vợ", "Chồng", "Bố", "Mẹ", "Khác"].map((
                      relation,
                    ) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 56) / 3,
                        child: _buildSelectBox(
                          relation,
                          null,
                          selectedRelation == relation,
                          (val) => setState(() => selectedRelation = val),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting || !_isFormValid ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26BC9B),
                  disabledBackgroundColor: const Color(0xFFA8DADC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        "HOÀN TẤT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 10),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobCtrl.text = _formatDisplayDate(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    final viewModel = context.read<ProfileViewModel>();

    final request = AddRelativeRequest(
      fullname: _nameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim(),
      identityNumber: _identityCtrl.text.trim(),
      gender: selectedGender,
      dateOfBirth: _selectedDob != null
          ? _formatRequestDate(_selectedDob!)
          : _dobCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim().isEmpty
          ? null
          : _phoneCtrl.text.trim(),
      relationship: selectedRelation,
    );

    final result = await viewModel.addRelative(
      request,
      avatarFile: _avatarFile,
    );
    if (!mounted) return;

    if (result != null && result.status == 'CREATED') {
      Navigator.pop(context, true);
    } else if (result != null && result.status == 'LINK_REQUEST_CREATED') {
      AppNotifier.warning(
        context,
        result.message.isNotEmpty
            ? result.message
            : 'Hồ sơ đã tồn tại. Yêu cầu liên kết đang chờ phê duyệt.',
      );
      Navigator.pop(context, false);
    } else {
      final message = viewModel.addErrorMessage ?? 'Không thể thêm hồ sơ mới.';
      AppNotifier.error(context, message);
    }
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF26BC9B)),
          ),
          suffixIcon: readOnly
              ? const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF26BC9B),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSelectBox(
    String label,
    IconData? icon,
    bool isActive,
    Function(String) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF26BC9B).withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF26BC9B) : Colors.transparent,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 18,
                    color: isActive ? const Color(0xFF26BC9B) : Colors.grey,
                  ),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF26BC9B)
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (isActive)
              const Positioned(
                right: 4,
                top: 0,
                child: Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Color(0xFF26BC9B),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }

  String _formatRequestDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "${date.year}-$month-$day";
  }

  Future<void> _pickAvatar() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      AppNotifier.error(
        context,
        error.message ?? 'Không thể truy cập thư viện ảnh.',
      );
    }
  }
}
