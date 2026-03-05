import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:frontend/utils/custom_text_field.dart';
import 'package:frontend/viewmodels/login_view_model.dart';
import 'package:frontend/viewmodels/register_view_model.dart';
import 'package:frontend/views/otp_screen.dart';
import 'package:provider/provider.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

enum ForgotPasswordStep { inputEmail, inputNewPassword }

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showForgotPasswordTab = false;
  ForgotPasswordStep _currentStep = ForgotPasswordStep.inputEmail;

  // Controllers cho Login
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Controllers cho Register
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _enableForgotPasswordTab() {
    setState(() {
      _showForgotPasswordTab = true;
      _tabController.animateTo(1);
    });
  }

  void _disableForgotPasswordTab() {
    setState(() {
      _showForgotPasswordTab = false;
      _tabController.animateTo(0);
    });
  }

  void _onOtpVerifiedSuccess() {
    setState(() {
      _currentStep = ForgotPasswordStep.inputNewPassword;
      _showForgotPasswordTab = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300), // Thời gian ẩn/hiện
            curve: Curves.easeInOut,
            width: double.infinity,
            // Nếu bàn phím hiện thì chiều cao bằng 0, ngược lại bằng 40% màn hình
            height: isKeyboardVisible
                ? 0
                : MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              // Dùng cái này để tránh lỗi overflow khi đang co lại
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: const Image(
                  image: AssetImage('assets/images/login_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: isKeyboardVisible
                ? MediaQuery.of(context).padding.top + 10
                : 20,
          ),

          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              const Tab(text: "Đăng ký"),
              Tab(text: _showForgotPasswordTab ? "Quên mật khẩu" : "Đăng nhập"),
            ],
          ),

          const SizedBox(height: 30),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRegisterForm(),
                _showForgotPasswordTab
                    ? _buildForgotPasswordStepContent()
                    : _buildLoginForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final isLoading = context.watch<LoginViewModel>().isLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CustomTextField(label: "Email", controller: _loginEmailController),
          const SizedBox(height: 20),
          CustomTextField(
            label: "Mật khẩu",
            isPassword: true,
            controller: _loginPasswordController,
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (v) {},
                    activeColor: const Color(0xFF76D7C4),
                  ),
                  const Text(
                    "Nhớ thông tin đăng nhập",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              TextButton(
                onPressed: _enableForgotPasswordTab,
                child: const Text(
                  "Quên mật khẩu?",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          _buildActionButton(
            "Đăng nhập",
            onTap: isLoading ? null : () => _handleLogin(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    final errorMessage = context.watch<RegisterViewModel>().errorMessage;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CustomTextField(
            label: "Email",
            controller: _registerEmailController,
            errorText: errorMessage?['email']?.toString(),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: "Mật khẩu",
            isPassword: true,
            controller: _registerPasswordController,
            errorText: errorMessage?['password']?.toString(),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: "Xác nhận mật khẩu",
            isPassword: true,
            controller: _registerConfirmPasswordController,
            errorText: errorMessage?['confirmPassword']?.toString(),
          ),

          const SizedBox(height: 30),
          _buildActionButton(
            "Đăng ký ngay",
            onTap: () => _handleRegister(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, {VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF8DE9D5), Color(0xFF76D7C4)],
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Xin vui lòng nhập email:",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          const CustomTextField(label: "Email"),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  "Quay lại",
                  _disableForgotPasswordTab,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionButton(
                  "Lấy mã OTP",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OtpScreen(onVerifiedSuccess: _onOtpVerifiedSuccess),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFFF9B886),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewPasswordForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Xin vui lòng nhập email:",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 15),
          const CustomTextField(label: "Mật khẩu mới", isPassword: true),
          const SizedBox(height: 20),
          const CustomTextField(
            label: "Nhập lại mật khẩu mới",
            isPassword: true,
          ),
          const SizedBox(height: 40),
          _buildActionButton(
            "Xác nhận",
            onTap: () {
              // Xử lý cập nhật mật khẩu lên server tại đây
              print("Cập nhật mật khẩu thành công!");
              _disableForgotPasswordTab();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordStepContent() {
    if (_currentStep == ForgotPasswordStep.inputEmail) {
      return _buildForgotPasswordForm();
    } else {
      return _buildNewPasswordForm();
    }
  }

  void _handleLogin(BuildContext context) async {
    final viewModel = context.read<LoginViewModel>();

    final success = await viewModel.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRegister(BuildContext context) async {
    final viewModel = context.read<RegisterViewModel>();
    final password = _registerPasswordController.text.trim();
    final confirmPassword = _registerConfirmPasswordController.text.trim();
    if (password != confirmPassword) {
      viewModel.errorMessage = {
        'confirmPassword': 'Mật khẩu xác nhận không khớp',
      };
      return;
    }
    final success = await viewModel.register(
      _registerEmailController.text.trim(),
      _registerPasswordController.text.trim(),
    );
    if (success && mounted) {
      Fluttertoast.showToast(
        msg: "Đăng ký thành công! Vui lòng đăng nhập.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP, // Đẩy lên trên đầu
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      _registerEmailController.clear();
      _registerPasswordController.clear();
      _registerConfirmPasswordController.clear();

      viewModel.clearErrors();
      _tabController.animateTo(1); // Chuyển sang tab Đăng nhập
    } else if (viewModel.errorMessage != null && mounted) {
      Fluttertoast.showToast(
        msg: viewModel.errorMessage.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
