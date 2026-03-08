import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:frontend/views/medical-record/medical_timeline_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theo dõi trạng thái từ ViewModel
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 30),
                const Text("Sign In", style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 10),
                const Text("Hi! Welcome back, you've been missed", style: TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 40),

                _buildInputLabel("Email"),
                _buildEmailField(authVM),
                const SizedBox(height: 20),

                _buildInputLabel("Password"),
                _buildPasswordField(authVM),

                // Hiển thị thông báo lỗi nếu có
                if (authVM.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(authVM.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF246BFF), fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 30),

                _buildSignInButton(context, authVM),
                const SizedBox(height: 30),
                _buildSignUpOption(context),
              ],
            ),
          ),
          
          // Hiển thị Loading Overlay khi đang gọi API
          if (authVM.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF246BFF))),
            ),
        ],
      ),
    );
  }

  // --- Widget Components ---

  Widget _buildLogo() => Container(
        width: 100, height: 100,
        decoration: const BoxDecoration(color: Color(0xFF246BFF), shape: BoxShape.circle),
        child: const Center(child: Icon(Icons.favorite, color: Colors.white, size: 50)),
      );

  Widget _buildEmailField(AuthViewModel vm) => TextField(
        controller: _emailController,
        onChanged: (_) => vm.clearError(), // Xóa lỗi khi người dùng nhập lại
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: "Enter your email",
          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF246BFF)),
          filled: true, fillColor: const Color(0xFFDDE3FF).withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      );

  Widget _buildPasswordField(AuthViewModel vm) => TextField(
        controller: _passwordController,
        onChanged: (_) => vm.clearError(),
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: "Enter your password",
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF246BFF)),
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF246BFF)),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          filled: true, fillColor: const Color(0xFFDDE3FF).withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      );

  Widget _buildSignInButton(BuildContext context, AuthViewModel vm) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF246BFF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const StadiumBorder(), elevation: 0,
          ),
          onPressed: vm.isLoading ? null : () async {
            // Thực hiện đăng nhập
            final success = await vm.login(
              _emailController.text.trim(),
              _passwordController.text,
            );

            if (success && mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          child: const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      );

  Widget _buildSignUpOption(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?", style: TextStyle(color: Colors.black54)),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            child: const Text("Sign Up", style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
          ),
        ],
      );

  Widget _buildInputLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
        child: Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
      );
}