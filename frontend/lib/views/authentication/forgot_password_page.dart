import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import 'forgot_password_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nhập email tài khoản để nhận mã OTP đặt lại mật khẩu.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return 'Email không được để trống';
                  }
                  if (!text.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _requestOtp,
                child: const Text('Gửi OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final vm = context.read<AuthViewModel>();
    final success = await vm.requestForgotPasswordOtp(email);

    if (!mounted) {
      return;
    }

    if (!success) {
      AppNotifier.error(context, vm.errorMessage ?? 'Không thể gửi OTP');
      return;
    }

    AppNotifier.success(context, 'OTP đã được gửi tới email của bạn');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordOtpPage(email: email),
      ),
    );
  }
}
