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
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _otpVerified = false;

  @override
  void dispose() {
    _otpController.dispose();
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
              _buildLabel('OTP:', isRequired: true),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                enabled: !vm.isLoading,
                decoration: _inputDecoration('Nhập mã OTP 6 số'),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return 'OTP không được để trống';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(text)) {
                    return 'OTP phải gồm đúng 6 chữ số';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: vm.isLoading ? null : _sendOtp,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF246BFF),
                        side: const BorderSide(color: Color(0xFF246BFF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Gửi OTP'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Xác thực OTP'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Mật khẩu mới:', isRequired: true),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                enabled: _otpVerified && !vm.isLoading,
                decoration: _inputDecoration('Nhập mật khẩu mới'),
                validator: (value) {
                  if (!_otpVerified) {
                    return null;
                  }
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
                obscureText: true,
                enabled: _otpVerified && !vm.isLoading,
                decoration: _inputDecoration('Nhập lại mật khẩu mới'),
                validator: (value) {
                  if (!_otpVerified) {
                    return null;
                  }
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
                onPressed: (!_otpVerified || vm.isLoading)
                    ? null
                    : _changePassword,
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

  Future<void> _sendOtp() async {
    final vm = context.read<UserViewModel>();
    final ok = await vm.requestPasswordOtp();
    if (!mounted) return;

    if (ok) {
      setState(() {
        _otpSent = true;
        _otpVerified = false;
      });
    }

    if (ok) {
      AppNotifier.success(context, 'OTP đã gửi qua email');
    } else {
      AppNotifier.error(context, 'Không thể gửi OTP');
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<UserViewModel>();
    final ok = await vm.verifyPasswordOtp(otp: _otpController.text.trim());
    if (!mounted) return;

    if (ok) {
      setState(() {
        _otpVerified = true;
      });
    }

    if (ok) {
      AppNotifier.success(context, 'OTP hợp lệ');
    } else {
      AppNotifier.error(context, 'OTP không hợp lệ hoặc đã hết hạn');
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<UserViewModel>();
    final ok = await vm.updatePasswordWithOtp(
      otp: _otpController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      AppNotifier.success(context, 'Đổi mật khẩu thành công');
    } else {
      AppNotifier.error(context, 'Đổi mật khẩu thất bại');
    }

    if (ok) {
      setState(() {
        _otpSent = false;
        _otpVerified = false;
      });
      _otpController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFDDE3FF).withValues(alpha: 0.4),
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
