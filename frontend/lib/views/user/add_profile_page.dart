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
  // ── Constants ──────────────────────────────────────────
  static const Color _primaryBlue = Color(0xFF246BFF);
  static const Color _textMain = Color(0xFF1F2A44);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _bgField = Color(0xFFF9FAFB);

  // ── Controllers ────────────────────────────────────────
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _identityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();
  final _chronicDiseaseCtrl = TextEditingController();
  final _clinicalNotesCtrl = TextEditingController();

  File? _avatarFile;
  String? _selectedGender;
  String? _selectedRelation;
  String _selectedBloodGroup = 'Chưa xác định';
  DateTime? _selectedDob;

  final _genderOptions = ['Nam', 'Nữ'];
  final _relationOptions = ['Con', 'Vợ', 'Chồng', 'Bố', 'Mẹ', 'Anh/Chị/Em', 'Khác'];
  final _bloodOptions = ['Chưa xác định', 'A', 'B', 'AB', 'O'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _identityCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _allergyCtrl.dispose();
    _chronicDiseaseCtrl.dispose();
    _clinicalNotesCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final isSubmitting = vm.isAddLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm thành viên',
          style: TextStyle(color: _textMain, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar Section ──
                    _buildAvatarSection(),
                    const SizedBox(height: 28),

                    // ── Họ và tên ──
                    _buildLabel('Họ và tên', required: true),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _nameCtrl,
                      hint: 'Nhập họ và tên',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),
                    const SizedBox(height: 18),

                    // ── Tên thân mật ──
                    _buildLabel('Tên thân mật'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _nicknameCtrl,
                      hint: 'Nhập tên thân mật (nếu có)',
                    ),
                    const SizedBox(height: 18),

                    // ── Giới tính + Mối quan hệ ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Giới tính', required: true),
                              const SizedBox(height: 6),
                              _buildDropdown(
                                value: _selectedGender,
                                hint: 'Chọn',
                                items: _genderOptions,
                                onChanged: (v) => setState(() => _selectedGender = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Mối quan hệ', required: true),
                              const SizedBox(height: 6),
                              _buildDropdown(
                                value: _selectedRelation,
                                hint: 'Chọn',
                                items: _relationOptions,
                                onChanged: (v) => setState(() => _selectedRelation = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── CCCD ──
                    _buildLabel('CCCD / Định danh', required: true),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _identityCtrl,
                      hint: 'Nhập số CCCD/CMND',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập CCCD' : null,
                    ),
                    const SizedBox(height: 18),

                    // ── Ngày sinh ──
                    _buildLabel('Ngày sinh', required: true),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _dobCtrl,
                      hint: '',
                      readOnly: true,
                      onTap: _pickDob,
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng chọn ngày sinh' : null,
                    ),
                    const SizedBox(height: 18),

                    // ── Số điện thoại ──
                    _buildLabel('Số điện thoại'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _phoneCtrl,
                      hint: 'Nhập số điện thoại',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),

                    // ── Health Section ──
                    _buildHealthSectionHeader(),
                    const SizedBox(height: 18),

                    _buildLabel('Nhóm máu'),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: _selectedBloodGroup,
                      hint: 'Chọn nhóm máu',
                      items: _bloodOptions,
                      onChanged: (v) => setState(() => _selectedBloodGroup = v ?? 'Chưa xác định'),
                    ),
                    const SizedBox(height: 18),

                    _buildHealthLabel(Icons.warning_amber_rounded, 'Dị ứng (nếu có)'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _allergyCtrl,
                      hint: 'Nhập các loại dị ứng thực ăn, thuốc...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Bệnh mãn tính'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _chronicDiseaseCtrl,
                      hint: 'Nhập các bệnh mãn tính đang điều trị',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),

                    _buildHealthLabel(Icons.description_outlined, 'Ghi chú lâm sàng'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _clinicalNotesCtrl,
                      hint: 'Ghi chú thêm từ bác sĩ hoặc cá nhân',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Buttons ──
          _buildBottomBar(isSubmitting),
        ],
      ),
    );
  }

  // ── Avatar Section ─────────────────────────────────────

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEF0F7),
              border: Border.all(color: const Color(0xFFDDE3F0), width: 3),
            ),
            child: ClipOval(
              child: _avatarFile != null
                  ? Image.file(_avatarFile!, fit: BoxFit.cover, width: 100, height: 100)
                  : const Icon(Icons.person_outline_rounded, size: 50, color: Color(0xFF9CA3C5)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatarButton(Icons.upload_outlined, 'Tải ảnh', () => _pickAvatarFrom(ImageSource.gallery)),
              const SizedBox(width: 24),
              _buildAvatarButton(Icons.camera_alt_outlined, 'Chụp ảnh', () => _pickAvatarFrom(ImageSource.camera)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: _textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: _textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Labels ─────────────────────────────────────────────

  Widget _buildLabel(String text, {bool required = false}) {
    if (!required) {
      return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain),
        children: [
          TextSpan(text: text),
          const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHealthSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.favorite_outline_rounded, size: 18, color: Color(0xFFE84B7A)),
        ),
        const SizedBox(width: 10),
        const Text(
          'Thông tin sức khỏe',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textMain),
        ),
      ],
    );
  }

  Widget _buildHealthLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _textMuted),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain)),
      ],
    );
  }

  // ── Input Field ────────────────────────────────────────

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: _bgField,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: _textMuted) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  // ── Dropdown ───────────────────────────────────────────

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _bgField,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 14, color: _textMain)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────

  Widget _buildBottomBar(bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Hủy', style: TextStyle(color: _textMuted, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu thành viên', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────

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

  Future<void> _pickAvatarFrom(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      AppNotifier.error(context, error.message ?? 'Không thể truy cập ảnh.');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      AppNotifier.error(context, 'Vui lòng chọn giới tính.');
      return;
    }
    if (_selectedRelation == null) {
      AppNotifier.error(context, 'Vui lòng chọn mối quan hệ.');
      return;
    }

    FocusScope.of(context).unfocus();
    final viewModel = context.read<ProfileViewModel>();

    final request = AddRelativeRequest(
      fullname: _nameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim().isNotEmpty ? _nicknameCtrl.text.trim() : _nameCtrl.text.trim(),
      identityNumber: _identityCtrl.text.trim(),
      gender: _selectedGender!,
      dateOfBirth: _selectedDob != null ? _formatRequestDate(_selectedDob!) : _dobCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      allergy: _allergyCtrl.text.trim().isEmpty ? null : _allergyCtrl.text.trim(),
      chronicDisease: _chronicDiseaseCtrl.text.trim().isEmpty ? null : _chronicDiseaseCtrl.text.trim(),
      clinicalNotes: _clinicalNotesCtrl.text.trim().isEmpty ? null : _clinicalNotesCtrl.text.trim(),
      bloodGroup: _selectedBloodGroup,
      relationship: _selectedRelation!,
    );

    final result = await viewModel.addRelative(request, avatarFile: _avatarFile);
    if (!mounted) return;

    if (result != null && result.status == 'CREATED') {
      Navigator.pop(context, true);
    } else if (result != null && result.status == 'LINK_REQUEST_CREATED') {
      AppNotifier.warning(
        context,
        result.message.isNotEmpty ? result.message : 'Hồ sơ đã tồn tại. Yêu cầu liên kết đang chờ phê duyệt.',
      );
      Navigator.pop(context, false);
    } else {
      final message = viewModel.addErrorMessage ?? 'Không thể thêm hồ sơ mới.';
      AppNotifier.error(context, message);
    }
  }

  // ── Formatters ─────────────────────────────────────────

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatRequestDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
