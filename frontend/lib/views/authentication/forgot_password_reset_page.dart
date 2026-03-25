import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgotPasswordResetPage extends StatefulWidget {
  final String email;
  final String otp;

  const ForgotPasswordResetPage({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ForgotPasswordResetPage> createState() => _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Đặt mật khẩu mới cho ${widget.email}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: const OutlineInputBorder(),
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
                  if (text.length < 6 || text.length > 20) {
                    return 'Mật khẩu phải từ 6 đến 20 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  border: const OutlineInputBorder(),
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
                  if ((value ?? '').trim() != _newPasswordController.text.trim()) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _resetPassword,
                child: const Text('Cập nhật mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.resetForgotPassword(
      email: widget.email,
      otp: widget.otp,
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      AppNotifier.error(context, vm.errorMessage ?? 'Không thể đặt lại mật khẩu');
      return;
    }

    AppNotifier.success(context, 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập.');
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
