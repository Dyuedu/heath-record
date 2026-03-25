import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  bool _initialized = false;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<UserViewModel>();
      if (vm.profile == null) {
        vm.loadMyProfile();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final profile = vm.profile;

    if (!_initialized && profile != null) {
      _fullNameController.text = profile.fullName;
      _phoneController.text = profile.phoneNumber;
      _dobController.text = profile.dateOfBirth;
      _selectedGender = _normalizeGenderValue(profile.gender);
      _addressController.text = profile.address;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: profile == null && vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInput(
                      label: 'Họ và tên:',
                      controller: _fullNameController,
                      serverErrorText: vm.fieldErrors['fullName'],
                      onChanged: (_) => vm.clearMessages(),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Họ và tên không được để trống';
                        }
                        if (text.length < 2) {
                          return 'Họ và tên phải có ít nhất 2 ký tự';
                        }
                        return null;
                      },
                    ),
                    _buildInput(
                      label: 'Số điện thoại:',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      serverErrorText:
                          vm.fieldErrors['phoneNumber'] ??
                          vm.fieldErrors['phone'],
                      onChanged: (_) => vm.clearMessages(),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Số điện thoại không được để trống';
                        }
                        final phoneRegex = RegExp(r'^\+?[0-9]{9,11}$');
                        if (!phoneRegex.hasMatch(text)) {
                          return 'Số điện thoại phải từ 9-11 chữ số';
                        }
                        return null;
                      },
                    ),
                    _buildGenderInput(),
                    _buildInput(
                      label: 'Ngày sinh (yyyy-MM-dd hoặc dd/MM/yyyy):',
                      controller: _dobController,
                      keyboardType: TextInputType.datetime,
                      serverErrorText: vm.fieldErrors['dateOfBirth'],
                      onChanged: (_) => vm.clearMessages(),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                        onPressed: _pickDate,
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Ngày sinh không được để trống';
                        }
                        if (_normalizeDateInput(text) == null) {
                          return 'Ngày sinh không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    _buildInput(
                      label: 'Địa chỉ:',
                      controller: _addressController,
                      serverErrorText: vm.fieldErrors['address'],
                      onChanged: (_) => vm.clearMessages(),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Địa chỉ không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: vm.isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Lưu thay đổi'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<UserViewModel>();
    final normalizedDob = _normalizeDateInput(_dobController.text.trim());
    if (normalizedDob == null || _selectedGender == null) {
      AppNotifier.error(context, 'Dữ liệu hồ sơ chưa hợp lệ');
      return;
    }

    final success = await vm.updateMyProfile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gender: _selectedGender!,
      dateOfBirth: normalizedDob,
      address: _addressController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      AppNotifier.success(context, 'Cập nhật hồ sơ thành công');
    } else {
      AppNotifier.error(context, vm.errorMessage ?? 'Cập nhật hồ sơ thất bại');
    }

    if (success) {
      context.read<UserViewModel>().loadMyProfile();
    }
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? serverErrorText,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFDDE3FF).withValues(alpha: 0.45),
              suffixIcon: suffixIcon,
              errorText: serverErrorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorMaxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderInput() {
    final vm = context.watch<UserViewModel>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel('Giới tính:'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            items: const [
              DropdownMenuItem(value: 'Nam', child: Text('Nam')),
              DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
              context.read<UserViewModel>().clearMessages();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Giới tính không được để trống';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFDDE3FF).withValues(alpha: 0.45),
              errorText: vm.fieldErrors['gender'],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorMaxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final parsedExisting = _parseDateInput(_dobController.text.trim());
    final initialDate = parsedExisting ?? DateTime(now.year - 18);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      _dobController.text = _formatDateIso(picked);
    }
  }

  String? _normalizeDateInput(String input) {
    final date = _parseDateInput(input);
    if (date == null) return null;
    return _formatDateIso(date);
  }

  DateTime? _parseDateInput(String input) {
    final text = input.trim();
    if (text.isEmpty) return null;

    final iso = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (iso.hasMatch(text)) {
      return DateTime.tryParse(text);
    }

    final slash = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (slash.hasMatch(text)) {
      final parts = text.split('/');
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return null;
      final dt = DateTime(year, month, day);
      if (dt.year == year && dt.month == month && dt.day == day) {
        return dt;
      }
    }

    return null;
  }

  String _formatDateIso(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String? _normalizeGenderValue(String? gender) {
    final value = (gender ?? '').trim().toLowerCase();
    if (value == 'nam') return 'Nam';
    if (value == 'nữ' || value == 'nu') return 'Nữ';
    return null;
  }

  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
