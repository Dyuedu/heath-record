import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import 'forgot_password_reset_page.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpPage({super.key, required this.email});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh OTP'),
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
                'Nhập mã OTP đã gửi đến ${widget.email}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã OTP',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (!RegExp(r'^\d{6}$').hasMatch(text)) {
                    return 'OTP phải gồm 6 chữ số';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _verifyOtp,
                child: const Text('Xác minh OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final otp = _otpController.text.trim();
    final vm = context.read<AuthViewModel>();
    final success = await vm.verifyForgotPasswordOtp(widget.email, otp);

    if (!mounted) {
      return;
    }

    if (!success) {
      AppNotifier.error(context, vm.errorMessage ?? 'OTP không hợp lệ');
      return;
    }

    AppNotifier.success(context, 'Xác minh OTP thành công');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordResetPage(email: widget.email, otp: otp),
      ),
    );
  }
}
