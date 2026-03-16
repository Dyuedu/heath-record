import 'package:flutter/material.dart';
import 'package:frontend/data/models/admin/admin_user_payload.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const List<String> _roles = ['USER', 'DOCTOR', 'ADMIN'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _guardAndLoad();
    });
  }

  Future<void> _guardAndLoad() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.currentRole == null) {
      await authViewModel.refreshCurrentRole();
    }
    if (!mounted) return;
    if (!authViewModel.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không có quyền truy cập trang này.')),
      );
      Navigator.of(context).pop();
      return;
    }
    await context.read<AdminViewModel>().loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Quản lý người dùng'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B1D1F),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<AdminViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.users.isEmpty) {
            return _buildEmptyState(viewModel);
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AdminViewModel>().loadAllUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: viewModel.users.length,
              itemBuilder: (context, index) {
                final user = viewModel.users[index];
                return _UserCard(
                  user: user,
                  onTap: () => _showUserForm(user: user),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(),
        backgroundColor: const Color(0xFF246BFF),
        icon: const Icon(Icons.add),
        label: const Text('Thêm người dùng'),
      ),
    );
  }

  Widget _buildEmptyState(AdminViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Chưa có người dùng nào.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ??
                  'Nhấn nút bên dưới để thêm người dùng đầu tiên.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<AdminViewModel>().loadAllUsers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserForm({UserProfileModel? user}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _AdminUserDialog(user: user, roles: _roles);
      },
    );

    if (!mounted || result == null) return;

    final adminViewModel = context.read<AdminViewModel>();
    final message = result
        ? (adminViewModel.successMessage ?? 'Thao tác thành công.')
        : (adminViewModel.errorMessage ?? 'Thao tác thất bại.');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _UserCard extends StatelessWidget {
  final UserProfileModel user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayName = user.fullName.isEmpty ? 'Chưa cập nhật' : user.fullName;
    final email = user.email.isEmpty ? 'Không có email' : user.email;
    final subtitle = user.phoneNumber.isEmpty
        ? email
        : '$email • ${user.phoneNumber}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF26BC9B).withOpacity(0.15),
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF26BC9B),
            ),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ),
        trailing: Chip(
          backgroundColor: _roleColor(user.role),
          label: Text(
            _normalizeRole(user.role),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  static Color _roleColor(String role) {
    final normalized = _normalizeRole(role);
    switch (normalized) {
      case 'ADMIN':
        return const Color(0xFFEF476F);
      case 'DOCTOR':
        return const Color(0xFF118AB2);
      default:
        return const Color(0xFF06D6A0);
    }
  }

  static String _normalizeRole(String role) {
    if (role.isEmpty) return 'USER';
    final upper = role.toUpperCase();
    if (upper.startsWith('ROLE_')) {
      return upper.substring(5);
    }
    return upper;
  }
}

class _AdminUserDialog extends StatefulWidget {
  final UserProfileModel? user;
  final List<String> roles;

  const _AdminUserDialog({required this.user, required this.roles});

  @override
  State<_AdminUserDialog> createState() => _AdminUserDialogState();
}

class _AdminUserDialogState extends State<_AdminUserDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _genderController;
  late final TextEditingController _dobController;
  late final TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _genderController = TextEditingController(text: user?.gender ?? '');
    _dobController = TextEditingController(text: user?.dateOfBirth ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _selectedRole = _UserCard._normalizeRole(user?.role ?? 'USER');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Consumer<AdminViewModel>(
      builder: (context, viewModel, _) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(isEdit ? 'Cập nhật người dùng' : 'Thêm người dùng'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Họ tên *',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Họ tên là bắt buộc'
                        : null,
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Email là bắt buộc'
                        : null,
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại *',
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Số điện thoại là bắt buộc'
                        : null,
                  ),
                  if (!isEdit)
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu *',
                      obscureText: true,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Mật khẩu là bắt buộc'
                          : null,
                    )
                  else
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu mới (tuỳ chọn)',
                      obscureText: true,
                    ),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Vai trò *'),
                    items: widget.roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                  _buildTextField(
                    controller: _genderController,
                    label: 'Giới tính',
                  ),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dobController,
                        label: 'Ngày sinh (yyyy-MM-dd)',
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Địa chỉ',
                    maxLines: 2,
                  ),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Hủy bỏ'),
            ),
            ElevatedButton(
              onPressed: viewModel.isSaving
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() != true) return;
                      final payload = AdminUserPayload(
                        fullName: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phoneNumber: _phoneController.text.trim(),
                        password: _passwordController.text.trim().isEmpty
                            ? null
                            : _passwordController.text.trim(),
                        role: _selectedRole,
                        gender: _genderController.text.trim().isEmpty
                            ? null
                            : _genderController.text.trim(),
                        dateOfBirth: _dobController.text.trim().isEmpty
                            ? null
                            : _dobController.text.trim(),
                        address: _addressController.text.trim().isEmpty
                            ? null
                            : _addressController.text.trim(),
                      );

                      bool success;
                      if (isEdit) {
                        success = await viewModel.updateUser(
                          id: widget.user!.id,
                          payload: payload,
                        );
                      } else {
                        success = await viewModel.createUser(payload);
                      }

                      if (!mounted || !success) return;
                      Navigator.of(context).pop(true);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26BC9B),
              ),
              child: viewModel.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final currentText = _dobController.text;
    DateTime? initialDate;
    if (currentText.isNotEmpty) {
      try {
        initialDate = DateTime.parse(currentText);
      } catch (_) {}
    }
    initialDate ??= DateTime(2000, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dobController.text = _formatDate(picked);
      setState(() {});
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
