import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:frontend/views/authentication/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false; // Thêm state cho checkbox
  String? _lastNotifiedError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty && _lastNotifiedError != args) {
      _lastNotifiedError = args;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppNotifier.error(context, args);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 60.0,
            ),
            child: Column(
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                const Text(
                  "Hệ thống quản lý hồ sơ y tế thông minh cho gia đình Việt",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                _buildInputLabel("Email"),
                _buildTextField(
                  controller: _emailController,
                  hint: "name@example.com",
                  icon: Icons.email_outlined,
                  vm: authVM,
                ),
                const SizedBox(height: 20),

                _buildInputLabel("Mật khẩu"),
                _buildTextField(
                  controller: _passwordController,
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  vm: authVM,
                ),

                const SizedBox(height: 12),
                _buildRememberAndForgot(),

                const SizedBox(height: 30),
                _buildSignInButton(authVM),

                const SizedBox(height: 24),
                _buildDivider(),

                const SizedBox(height: 24),
                _buildSignUpOption(context),

                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
          // Giữ nguyên logic Loading Overlay của bạn
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

  // --- UI Components Refactored ---

  Widget _buildLogo() => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E), // Màu nền logo tối
      borderRadius: BorderRadius.circular(16),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/logo.png', // Thay đường dẫn của bạn tại đây
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.analytics_outlined, color: Colors.white, size: 40),
      ),
    ),
  );

  Widget _buildInputLabel(String label) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required AuthViewModel vm,
  }) => TextField(
    controller: controller,
    obscureText: isPassword && !_isPasswordVisible,
    onChanged: (_) => vm.clearError(),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off_outlined,
                color: Colors.black45,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
      ),
    ),
  );

  Widget _buildRememberAndForgot() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (val) => setState(() => _rememberMe = val!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: const Color(0xFF007BFF),
            ),
          ),
          const Text(
            " Ghi nhớ tôi",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
          );
        },
        child: const Text(
          "Quên mật khẩu?",
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    ],
  );

  Widget _buildSignInButton(AuthViewModel vm) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      onPressed: vm.isLoading
          ? null
          : () async {
              // Giữ nguyên logic login cũ của bạn
              final success = await vm.login(
                _emailController.text.trim(),
                _passwordController.text,
              );
              if (success && mounted) {
                final targetRoute = vm.isAdmin
                    ? AppRouter.admin
                    : AppRouter.home;
                Navigator.pushReplacementNamed(context, targetRoute);
              }
            },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Đăng nhập",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    ),
  );

  Widget _buildDivider() => Row(
    children: [
      const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "HOẶC",
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
    ],
  );

  Widget _buildSignUpOption(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Bạn chưa có tài khoản? ",
        style: TextStyle(color: Colors.black54),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/signup'),
        child: const Text(
          "Đăng ký ngay",
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );

  Widget _buildFooter() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.5),
            children: [
              TextSpan(text: "Bằng việc đăng nhập, bạn đồng ý với "),
              TextSpan(
                text: "Điều khoản dịch vụ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.black87,
                ),
              ),
              TextSpan(text: " và "),
              TextSpan(
                text: "Chính sách bảo mật",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.black87,
                ),
              ),
              TextSpan(text: " của chúng tôi."),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        "Phiên bản 2.4.0 • Health Record JSC",
        style: TextStyle(color: Colors.black26, fontSize: 10),
      ),
    ],
  );
}
