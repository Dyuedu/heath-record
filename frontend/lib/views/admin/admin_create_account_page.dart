import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/data/models/admin/admin_user_payload.dart';
import 'package:frontend/utils/app_notifier.dart';

class AdminCreateAccountPage extends StatefulWidget {
  const AdminCreateAccountPage({super.key});

  @override
  State<AdminCreateAccountPage> createState() => _AdminCreateAccountPageState();
}

class _AdminCreateAccountPageState extends State<AdminCreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identityController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'doctor';
  bool _accountActive = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  static const Map<String, String> _roles = {
    'Bác sĩ': 'doctor',
    'Admin': 'admin',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      AppNotifier.error(context, 'Mật khẩu xác nhận không khớp');
      return;
    }

    final vm = context.read<AdminViewModel>();
    final payload = AdminUserPayload(
      fullName: _nameController.text.trim(),
      identityNumber: _selectedRole == 'admin' ? null : _identityController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      status: _accountActive ? 'ACTIVE' : 'LOCKED',
    );

    final success = await vm.createUser(payload);

    if (!mounted) return;

    if (success) {
      AppNotifier.success(context, vm.successMessage ?? 'Tạo tài khoản thành công');
      Navigator.pop(context);
    } else {
      AppNotifier.error(context, vm.errorMessage ?? 'Có lỗi xảy ra');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = _selectedRole == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF1F2A44),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tạo tài khoản mới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2A44),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section: Cấu hình hệ thống ──
                  _buildSectionHeader(Icons.settings_outlined, 'CẤU HÌNH HỆ THỐNG'),
                  const SizedBox(height: 16),

                  _buildLabeledField(
                    label: 'Vai trò người dùng',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
                          items: _roles.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.value,
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedRole = value);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account status toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_outlined, size: 20, color: Colors.grey.shade500),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trạng thái tài khoản',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2A44),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _accountActive
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : const Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _accountActive ? 'Sẵn sàng hoạt động' : 'Đã khóa',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _accountActive
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _accountActive,
                          onChanged: (v) => setState(() => _accountActive = v),
                          activeColor: const Color(0xFF246BFF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Section: Thông tin cá nhân ──
                  _buildSectionHeader(Icons.person_outline_rounded, 'THÔNG TIN BẮT BUỘC'),
                  const SizedBox(height: 16),

                  _buildLabeledField(
                    label: 'Họ và tên',
                    child: _buildTextField(
                      controller: _nameController,
                      hintText: 'VD: Nguyễn Văn An',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabeledField(
                    label: 'Số điện thoại',
                    child: _buildTextField(
                      controller: _phoneController,
                      hintText: '09XX XXX XXX',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!isAdmin) ...[
                    _buildLabeledField(
                      label: 'CCCD/CMND',
                      child: _buildTextField(
                        controller: _identityController,
                        hintText: 'Số CCCD/CMND',
                        prefixIcon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Vui lòng nhập số CCCD/CMND' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildLabeledField(
                    label: 'Email',
                    child: _buildTextField(
                      controller: _emailController,
                      hintText: 'email@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Vui lòng nhập email hợp lệ' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabeledField(
                    label: 'Mật khẩu',
                    child: _buildTextField(
                      controller: _passwordController,
                      hintText: 'Ít nhất 6 ký tự',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validator: (v) => v!.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabeledField(
                    label: 'Xác nhận mật khẩu',
                    child: _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Nhập lại mật khẩu',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      validator: (v) => v != _passwordController.text ? 'Mật khẩu không khớp' : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Action buttons ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: vm.isSaving ? null : _submitForm,
                      icon: vm.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        'Lưu tài khoản',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246BFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Hủy bỏ & Quay lại',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF246BFF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey.shade400),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
