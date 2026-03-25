import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('Mật khẩu cũ:', isRequired: true),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_showOldPassword,
                enabled: !vm.isLoading,
                decoration: _inputDecoration(
                  'Nhập mật khẩu cũ',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showOldPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showOldPassword = !_showOldPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return 'Mật khẩu cũ không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Mật khẩu mới:', isRequired: true),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                enabled: !vm.isLoading,
                decoration: _inputDecoration(
                  'Nhập mật khẩu mới',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return 'Mật khẩu mới không được để trống';
                  }
                  if (text.length < 6 || text.length > 20) {
                    return 'Mật khẩu mới phải từ 6 đến 20 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel('Xác nhận mật khẩu mới:', isRequired: true),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                enabled: !vm.isLoading,
                decoration: _inputDecoration(
                  'Nhập lại mật khẩu mới',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return 'Bạn cần xác nhận mật khẩu mới';
                  }
                  if (text != _newPasswordController.text.trim()) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF246BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Cập nhật mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<UserViewModel>();
    final ok = await vm.updatePassword(
      oldPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      AppNotifier.success(context, 'Đổi mật khẩu thành công');
    } else {
      AppNotifier.error(context, 'Đổi mật khẩu thất bại');
    }

    if (ok) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFDDE3FF).withValues(alpha: 0.4),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorMaxLines: 2,
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            TextSpan(text: text),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}
