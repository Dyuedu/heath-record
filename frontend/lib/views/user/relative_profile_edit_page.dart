import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/relative_profile_detail_model.dart';
import 'package:frontend/data/models/record/update_relative_profile_request.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/relative_detail_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RelativeProfileEditPage extends StatefulWidget {
  final String profileId;

  const RelativeProfileEditPage({
    super.key,
    required this.profileId,
  });

  @override
  State<RelativeProfileEditPage> createState() => _RelativeProfileEditPageState();
}

class _RelativeProfileEditPageState extends State<RelativeProfileEditPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _identityCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _gender = 'Nam';
  String _bloodGroup = 'Chưa xác định';
  File? _avatarFile;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeDetailViewModel>().loadRelativeProfile(widget.profileId);
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _nicknameCtrl.dispose();
    _identityCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _allergyCtrl.dispose();
    _chronicCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelativeDetailViewModel>();
    final detail = vm.profileDetail;

    if (!_initialized && detail != null) {
      _applyDetail(detail);
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF246BFF)),
        title: const Text(
          'Cập Nhật Hồ Sơ Người Thân',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: vm.isProfileLoading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _buildHeroCard(detail),
                  const SizedBox(height: 14),
                  _buildSectionCard(
                    title: 'Thông tin định danh',
                    icon: Icons.badge_outlined,
                    child: Column(
                      children: [
                        _buildInput(
                          controller: _fullNameCtrl,
                          label: 'Họ và tên',
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) return 'Không được để trống';
                            if (text.length < 2) return 'Ít nhất 2 ký tự';
                            return null;
                          },
                        ),
                        _buildInput(
                          controller: _nicknameCtrl,
                          label: 'Tên thân mật',
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Không được để trống';
                            }
                            return null;
                          },
                        ),
                        _buildInput(
                          controller: _identityCtrl,
                          label: 'Số CCCD/CMND',
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          helperText: 'Đã khóa chỉnh sửa do chưa có cơ chế xác thực CCCD mới.',
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Không được để trống';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Thông tin cá nhân',
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        _buildDateInput(),
                        const SizedBox(height: 10),
                        _buildGenderInput(),
                        const SizedBox(height: 10),
                        _buildInput(
                          controller: _phoneCtrl,
                          label: 'Số điện thoại',
                          keyboardType: TextInputType.phone,
                          readOnly: true,
                          helperText: 'Đã khóa chỉnh sửa do chưa có cơ chế xác thực SĐT mới.',
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Không được để trống';
                            }
                            return null;
                          },
                        ),
                        _buildInput(
                          controller: _addressCtrl,
                          label: 'Địa chỉ',
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Không được để trống';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Hồ sơ y tế',
                    icon: Icons.health_and_safety_outlined,
                    child: Column(
                      children: [
                        _buildBloodGroupInput(),
                        const SizedBox(height: 10),
                        _buildInput(
                          controller: _allergyCtrl,
                          label: 'Dị ứng (nếu có)',
                        ),
                        _buildInput(
                          controller: _chronicCtrl,
                          label: 'Bệnh mãn tính (nếu có)',
                        ),
                        _buildInput(
                          controller: _notesCtrl,
                          label: 'Ghi chú lâm sàng',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: vm.isUpdatingProfile ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246BFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: vm.isUpdatingProfile
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(vm.isUpdatingProfile ? 'Đang lưu...' : 'LƯU CẬP NHẬT'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard(RelativeProfileDetailModel? detail) {
    final relation = (detail?.relationship ?? '').trim();
    final name = (detail?.relativeName ?? '').trim().isEmpty
        ? 'Hồ sơ người thân'
        : detail!.relativeName.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF246BFF), Color(0xFF5B8CFF)],
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _avatarFile != null
                    ? Image.file(
                        _avatarFile!,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                      )
                    : _buildAvatarByUrl(detail?.avatarUrl),
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: _pickAndUploadAvatar,
                    icon: vmIcon(context),
                    tooltip: 'Tải ảnh đại diện',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  relation.isEmpty ? 'Hồ sơ y tế gia đình' : 'Quan hệ: $relation',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0E8A7B), size: 18),
              
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF246BFF),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4B5B7A), fontSize: 13),
          filled: true,
          fillColor: readOnly ? const Color(0xFFEFF3FB) : const Color(0xFFF5F8FF),
          helperText: helperText,
          helperStyle: const TextStyle(color: Color(0xFF6B7A99), fontSize: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: _dobCtrl,
      readOnly: true,
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Ngày sinh không được để trống';
        }
        return null;
      },
      onTap: _pickDate,
      decoration: InputDecoration(
        labelText: 'Ngày sinh',
        labelStyle: const TextStyle(color: Color(0xFF4B5B7A), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        suffixIcon: const Icon(Icons.calendar_month_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildGenderInput() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      items: const [
        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _gender = value);
      },
      decoration: InputDecoration(
        labelText: 'Giới tính',
        labelStyle: const TextStyle(color: Color(0xFF4B5B7A), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBloodGroupInput() {
    return DropdownButtonFormField<String>(
      initialValue: _bloodGroup,
      items: const [
        DropdownMenuItem(value: 'Chưa xác định', child: Text('Chưa xác định')),
        DropdownMenuItem(value: 'A', child: Text('A')),
        DropdownMenuItem(value: 'B', child: Text('B')),
        DropdownMenuItem(value: 'AB', child: Text('AB')),
        DropdownMenuItem(value: 'O', child: Text('O')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _bloodGroup = value);
      },
      decoration: InputDecoration(
        labelText: 'Nhóm máu',
        labelStyle: const TextStyle(color: Color(0xFF4B5B7A), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAvatarByUrl(String? avatarUrl) {
    final url = (avatarUrl ?? '').trim();
    if (url.isEmpty) {
      return Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.health_and_safety, color: Colors.white, size: 30),
      );
    }

    return Image.network(
      url,
      width: 62,
      height: 62,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.health_and_safety, color: Colors.white, size: 30),
        );
      },
    );
  }

  Widget vmIcon(BuildContext context) {
    final vm = context.watch<RelativeDetailViewModel>();
    if (vm.isUpdatingAvatar) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return const CircleAvatar(
      radius: 12,
      backgroundColor: Color(0xFF246BFF),
      child: Icon(Icons.camera_alt, color: Colors.white, size: 13),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final selected = File(picked.path);
    setState(() {
      _avatarFile = selected;
    });

    if (!mounted) return;
    final vm = context.read<RelativeDetailViewModel>();
    final success = await vm.uploadRelativeAvatar(widget.profileId, selected);
    if (!mounted) return;

    if (success) {
      AppNotifier.success(context, 'Cập nhật ảnh đại diện thành công');
    } else {
      AppNotifier.error(
        context,
        vm.profileUpdateMessage ?? 'Không thể cập nhật ảnh đại diện.',
      );
    }
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final existing = _parseDate(_dobCtrl.text.trim());

    final picked = await showDatePicker(
      context: context,
      initialDate: existing ?? DateTime(now.year - 10),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      _dobCtrl.text = _formatDateIso(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<RelativeDetailViewModel>();
    final request = UpdateRelativeProfileRequest(
      fullName: _fullNameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim(),
      identityNumber: _identityCtrl.text.trim(),
      gender: _gender,
      dateOfBirth: _dobCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      allergy: _cleanOptional(_allergyCtrl.text),
      chronicDisease: _cleanOptional(_chronicCtrl.text),
      clinicalNotes: _cleanOptional(_notesCtrl.text),
      bloodGroup: _bloodGroup,
    );

    final success = await vm.updateRelativeProfile(widget.profileId, request);
    if (!mounted) return;

    if (success) {
      AppNotifier.success(context, 'Cập nhật hồ sơ thành công');
      Navigator.pop(context, true);
      return;
    }

    AppNotifier.error(
      context,
      vm.profileUpdateMessage ?? 'Không thể cập nhật hồ sơ người thân.',
    );
  }

  void _applyDetail(RelativeProfileDetailModel detail) {
    _fullNameCtrl.text = detail.fullName ?? detail.relativeName;
    _nicknameCtrl.text = detail.nickname ?? '';
    _identityCtrl.text = detail.identityNumber ?? '';
    _gender = _normalizeGender(detail.gender);
    _dobCtrl.text = detail.dateOfBirth ?? '';
    _phoneCtrl.text = detail.phoneNumber ?? '';
    _addressCtrl.text = detail.address ?? '';
    _allergyCtrl.text = detail.allergy ?? '';
    _chronicCtrl.text = detail.chronicDisease ?? '';
    _notesCtrl.text = detail.clinicalNotes ?? '';
    _bloodGroup = _normalizeBloodGroup(detail.bloodGroup);
  }

  DateTime? _parseDate(String input) {
    if (input.isEmpty) return null;
    final iso = DateTime.tryParse(input);
    if (iso != null) return iso;

    final slash = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (slash.hasMatch(input)) {
      final parts = input.split('/');
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return null;
      return DateTime(year, month, day);
    }
    return null;
  }

  String _formatDateIso(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String? _cleanOptional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _normalizeGender(String? gender) {
    final g = (gender ?? '').trim().toLowerCase();
    if (g == 'nữ' || g == 'nu' || g == 'female') return 'Nữ';
    return 'Nam';
  }

  String _normalizeBloodGroup(String? bloodGroup) {
    const allowed = {'Chưa xác định', 'A', 'B', 'AB', 'O'};
    final value = (bloodGroup ?? '').trim();
    if (allowed.contains(value)) return value;
    return 'Chưa xác định';
  }
}
