import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart'; // Đảm bảo đúng đường dẫn

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Các hàm Validation ---
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập Email';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return 'Định dạng Email không hợp lệ';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
    final phoneRegExp = RegExp(r'^(0[3|5|7|8|9])([0-9]{8})$');
    if (!phoneRegExp.hasMatch(value)) return 'Số điện thoại không hợp lệ';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
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
    // Theo dõi ViewModel để lấy trạng thái Loading và Error
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color(0xFF246BFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Create an account to start managing health",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // Full Name
                  _buildInputLabel("Full Name"),
                  _buildTextFormField(
                    controller: _nameController,
                    hint: "Enter your full name",
                    icon: Icons.person_outline,
                    onChanged: (_) => authVM.clearError(),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  _buildInputLabel("Email"),
                  _buildTextFormField(
                    controller: _emailController,
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    onChanged: (_) => authVM.clearError(),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 15),

                  // Phone Number
                  _buildInputLabel("Phone Number"),
                  _buildTextFormField(
                    controller: _phoneController,
                    hint: "Enter your phone number",
                    icon: Icons.phone_android_outlined,
                    onChanged: (_) => authVM.clearError(),
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 15),

                  // Password
                  _buildInputLabel("Password"),
                  _buildPasswordField(
                    controller: _passwordController,
                    hint: "Create a password",
                    isVisible: _isPasswordVisible,
                    onToggle: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                    onChanged: (_) => authVM.clearError(),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  _buildInputLabel("Confirm Password"),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hint: "Confirm your password",
                    isVisible: _isConfirmPasswordVisible,
                    onToggle: () => setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                    onChanged: (_) => authVM.clearError(),
                    validator: _validateConfirmPassword,
                  ),

                  // Hiển thị lỗi từ Backend nếu có
                  if (authVM.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        authVM.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),

                  const SizedBox(height: 30),
                  _buildSignUpButton(context, authVM),
                  const SizedBox(height: 20),
                  _buildSignInOption(context),
                ],
              ),
            ),
          ),
          // Hiển thị vòng xoay loading đè lên màn hình
          if (authVM.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF246BFF)),
              ),
            ),
        ],
      ),
    );
  }

  // --- Widget Components ---

  Widget _buildLogo() => Container(
    width: 80,
    height: 80,
    decoration: const BoxDecoration(
      color: Color(0xFF246BFF),
      shape: BoxShape.circle,
    ),
    child: const Center(
      child: Icon(Icons.favorite, color: Colors.white, size: 40),
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
        prefixIcon: Icon(icon, color: const Color(0xFF246BFF)),
        filled: true,
        fillColor: const Color(0xFFDDE3FF).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
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
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF246BFF)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF246BFF),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFDDE3FF).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context, AuthViewModel vm) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF246BFF),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      onPressed: vm.isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                // Gọi hàm register và nhận về kết quả bool
                final success = await vm.register(
                  _nameController.text.trim(),
                  _emailController.text.trim(),
                  _phoneController.text.trim(),
                  _passwordController.text,
                );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đăng ký thành công! Đang chuyển hướng..."),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Quay lại trang Login sau khi thành công
                  Navigator.pop(context);
                }
              }
            },
      child: const Text(
        "Sign Up",
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
        "Already have an account?",
        style: TextStyle(color: Colors.black54),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "Sign In",
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ),
  );
}
