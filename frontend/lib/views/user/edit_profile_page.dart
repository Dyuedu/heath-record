import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/user_viewmodel.dart';
import 'package:frontend/views/user/change_password_page.dart';
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
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  bool _initialized = false;

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
    _genderController.dispose();
    _addressController.dispose();
    _avatarUrlController.dispose();
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
      _genderController.text = profile.gender;
      _addressController.text = profile.address;
      _avatarUrlController.text = profile.avatarUrl;
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
                    _buildInput(
                      label: 'Giới tính:',
                      controller: _genderController,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Giới tính không được để trống';
                        }
                        return null;
                      },
                    ),
                    _buildInput(
                      label: 'Ngày sinh (yyyy-MM-dd):',
                      controller: _dobController,
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Ngày sinh không được để trống';
                        }
                        final dobRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                        if (!dobRegex.hasMatch(text)) {
                          return 'Ngày sinh phải đúng định dạng yyyy-MM-dd';
                        }
                        return null;
                      },
                    ),
                    _buildInput(
                      label: 'Địa chỉ:',
                      controller: _addressController,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Địa chỉ không được để trống';
                        }
                        return null;
                      },
                    ),
                    _buildInput(
                      label: 'Avatar URL:',
                      controller: _avatarUrlController,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return null;
                        }
                        final uri = Uri.tryParse(text);
                        if (uri == null ||
                            !(uri.isScheme('http') || uri.isScheme('https'))) {
                          return 'Avatar URL phải là link http/https hợp lệ';
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
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF246BFF),
                        side: const BorderSide(color: Color(0xFF246BFF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.password_outlined),
                      label: const Text('Đổi mật khẩu'),
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (vm.successMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
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
    final success = await vm.updateMyProfile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gender: _genderController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      address: _addressController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      AppNotifier.success(context, 'Cập nhật hồ sơ thành công');
    } else {
      AppNotifier.error(context, 'Cập nhật hồ sơ thất bại');
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFDDE3FF).withValues(alpha: 0.45),
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
}
