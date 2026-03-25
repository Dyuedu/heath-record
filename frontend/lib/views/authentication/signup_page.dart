import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'otp_verification_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _lastNotifiedError;

  @override
  void dispose() {
    _nameController.dispose();
    _identityNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Giữ nguyên các hàm Validation cũ của bạn ---
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập Email';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return 'Định dạng Email không hợp lệ';
    final serverError = context.read<AuthViewModel>().fieldErrors['email'];
    if (serverError != null && serverError.trim().isNotEmpty) {
      return serverError;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
    final phoneRegExp = RegExp(r'^(0[3|5|7|8|9])([0-9]{8})$');
    if (!phoneRegExp.hasMatch(value)) return 'Số điện thoại không hợp lệ';
    final serverError = context.read<AuthViewModel>().fieldErrors['phone'];
    if (serverError != null && serverError.trim().isNotEmpty) {
      return serverError;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  String? _validateIdentityNumber(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Vui lòng nhập CCCD/CMND';
    final compact = raw.replaceAll(RegExp(r'\s+'), '');
    final identityRegExp = RegExp(r'^\d{9,12}$');
    if (!identityRegExp.hasMatch(compact)) {
      return 'CCCD/CMND phải gồm 9-12 chữ số';
    }
    final fieldErrors = context.read<AuthViewModel>().fieldErrors;
    final serverError = fieldErrors['identityNumber'] ?? fieldErrors['identity'];
    if (serverError != null && serverError.trim().isNotEmpty) {
      return serverError;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    final errorMessage = authVM.errorMessage;
    if (errorMessage != null && errorMessage != _lastNotifiedError) {
      _lastNotifiedError = errorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppNotifier.error(context, errorMessage);
      });
    } else if (errorMessage == null) {
      _lastNotifiedError = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo tài khoản",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            color: Colors.deepPurple.shade50,
            thickness: 2,
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bắt đầu ngay",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Nhập thông tin bên dưới để đăng ký hồ sơ y tế.",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  const SizedBox(height: 32),

                  _buildInputLabel("Họ và tên", isRequired: true),
                  _buildTextFormField(
                    controller: _nameController,
                    hint: "Nguyễn Văn A",
                    icon: Icons.person_outline,
                    onChanged: (_) => authVM.clearError(),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel("Email", isRequired: true),
                  _buildTextFormField(
                    controller: _emailController,
                    hint: "vidu@email.com",
                    icon: Icons.email_outlined,
                    onChanged: (_) {
                      authVM.clearFieldError('email');
                      authVM.clearError();
                    },
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel("Số điện thoại", isRequired: true),
                  _buildTextFormField(
                    controller: _phoneController,
                    hint: "0987 654 321",
                    icon: Icons.phone_android_outlined,
                    onChanged: (_) {
                      authVM.clearFieldError('phone');
                      authVM.clearError();
                    },
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel("Số CCCD/CMND", isRequired: true),
                  _buildTextFormField(
                    controller: _identityNumberController,
                    hint: "Nhập số định danh của bạn",
                    icon: Icons.credit_card_outlined,
                    onChanged: (_) {
                      authVM.clearFieldError('identityNumber');
                      authVM.clearError();
                    },
                    keyboardType: TextInputType.number,
                    validator: _validateIdentityNumber,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel("Mật khẩu", isRequired: true),
                  _buildPasswordField(
                    controller: _passwordController,
                    hint: "••••••••",
                    isVisible: _isPasswordVisible,
                    onToggle: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                    onChanged: (_) => authVM.clearError(),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel("Xác nhận mật khẩu", isRequired: true),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hint: "••••••••",
                    isVisible: _isConfirmPasswordVisible,
                    onToggle: () => setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                    onChanged: (_) => authVM.clearError(),
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 24),
                  _buildFooterNotice(),
                  const SizedBox(height: 24),
                  _buildSignUpButton(context, authVM),
                  const SizedBox(height: 24),
                  _buildSignInOption(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (authVM.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF007BFF)),
              ),
            ),
        ],
      ),
    );
  }

  // --- Input Widgets Refactored ---
  Widget _buildInputLabel(String label, {bool isOptional = false, bool isRequired = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent),
                ),
            ],
          ),
        ),
        if (isOptional)
          const Text(
            "(Tùy chọn)",
            style: TextStyle(
              color: Colors.black26,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    ),
  );

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black45, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF007BFF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: !isVisible,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Colors.black45,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off_outlined,
            color: Colors.black45,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF007BFF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildFooterNotice() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.5),
          children: [
            TextSpan(text: "Bằng cách nhấn Đăng ký, bạn đồng ý với "),
            TextSpan(
              text: "Điều khoản dịch vụ",
              style: TextStyle(
                color: Color(0xFF007BFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " và "),
            TextSpan(
              text: "Chính sách bảo mật",
              style: TextStyle(
                color: Color(0xFF007BFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " của Health Record."),
          ],
        ),
      ),
    ),
  );

  // --- Giữ nguyên logic Register cũ của bạn ---
  Widget _buildSignUpButton(BuildContext context, AuthViewModel vm) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007BFF),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      onPressed: vm.isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                final result = await vm.registerWithResult(
                  _nameController.text.trim(),
                  _identityNumberController.text.trim(),
                  _emailController.text.trim(),
                  _phoneController.text.trim(),
                  _passwordController.text,
                );

                if (!context.mounted) return;
                if (result != null) {
                  if (result.isConfirmRequired) {
                    final shouldCreateLinkRequest =
                        await _showLinkConfirmDialog();
                    if (!context.mounted || !shouldCreateLinkRequest) return;
                    final confirmResult = await vm.registerWithResult(
                      _nameController.text.trim(),
                      _identityNumberController.text.trim(),
                      _emailController.text.trim(),
                      _phoneController.text.trim(),
                      _passwordController.text,
                      confirmLinkRequest: true,
                    );
                    if (!context.mounted) return;
                    if (confirmResult == null) {
                      _formKey.currentState?.validate();
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtpVerificationPage(
                          email: _emailController.text.trim(),
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerificationPage(
                        email: _emailController.text.trim(),
                      ),
                    ),
                  );
                } else {
                  _formKey.currentState?.validate();
                }
              }
            },
      child: const Text(
        "Đăng ký",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );

  Widget _buildSignInOption(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Bạn đã có tài khoản? ",
        style: TextStyle(color: Colors.black54),
      ),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text(
          "Đăng nhập ngay",
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );

  // --- Giữ nguyên logic Dialog cũ ---
  Future<bool> _showLinkConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thông tin đã tồn tại'),
          content: const Text(
            'Thông tin người dùng này đã tồn tại, bạn có muốn gửi yêu cầu liên kết thông tin?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
