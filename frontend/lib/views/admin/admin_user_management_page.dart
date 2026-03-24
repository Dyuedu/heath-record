import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/views/admin/admin_bottom_nav.dart';
import 'package:frontend/views/admin/admin_create_account_page.dart';
import 'package:frontend/views/admin/admin_dashboard_page.dart';
import 'package:frontend/views/admin/admin_pending_list_page.dart';
import 'package:frontend/views/admin/admin_user_detail_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';
class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = ['Tất cả', 'admin', 'doctor', 'user'];
  static const Map<String, String> _filterLabels = {
    'Tất cả': 'Tất cả',
    'admin': 'Admin',
    'doctor': 'Bác sĩ',
    'user': 'Bệnh nhân',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  void _loadUsers() {
    String? role = _selectedFilter == 0 ? null : _filters[_selectedFilter];
    String? search = _searchController.text.trim();
    if (search.isEmpty) search = null;
    
    context.read<AdminViewModel>().searchUsers(search: search, role: role);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Quản lý Người dùng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2A44),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCreateAccountPage()),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _loadUsers(),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tên hoặc email...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter chips + counts
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Row(
              children: [
                // Filter icon
                Icon(Icons.filter_list_rounded, color: Colors.grey.shade500, size: 20),
                const SizedBox(width: 10),
                // Filter chips
                ..._filters.asMap().entries.map((entry) {
                  final isSelected = _selectedFilter == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = entry.key);
                        _loadUsers();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF246BFF) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF246BFF) : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _filterLabels[entry.value] ?? entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // List header & body via Consumer
          Expanded(
            child: Consumer<AdminViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF246BFF)));
                }

                final users = viewModel.users;
                final activeCount = users.where((u) => u.status == 'ACTIVE').length;
                final lockedCount = users.where((u) => u.status == 'LOCKED').length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            'DANH SÁCH (${users.length})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          _statusBadge('$activeCount Hoạt động', const Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          _statusBadge('$lockedCount Khóa', const Color(0xFFEF4444)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: users.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                return _buildUserCard(users[index]);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildUserCard(UserProfileModel user) {
    final isActive = user.status == 'ACTIVE';
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminUserDetailPage(user: user)),
        );
        // Reload users when coming back in case status was changed
        _loadUsers();
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF246BFF).withOpacity(0.1),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xFF246BFF),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F2A44),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _roleColor(user.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _displayRole(user.role),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _roleColor(user.role),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final newStatus = isActive ? 'LOCKED' : 'ACTIVE';
                  _showLoadingOverlay(context);
                  await context.read<AdminViewModel>().updateUserStatus(user.id, newStatus);
                  if (context.mounted) Navigator.pop(context); // close overlay
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isActive ? 'Hoạt động' : 'Khóa',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  String _displayRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'doctor':
        return 'Bác sĩ';
      case 'user':
        return 'Bệnh nhân';
      default:
        return role;
    }
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return const Color(0xFF246BFF);
      case 'admin':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy người dùng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chúng tôi không tìm thấy kết quả nào phù hợp với tìm kiếm của bạn. Hãy thử thay đổi bộ lọc hoặc từ khoá.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedFilter = 0;
                });
                _loadUsers();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF246BFF),
                side: const BorderSide(color: Color(0xFF246BFF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Đặt lại bộ lọc'),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
        break;
      case 1:
        break; // Already here
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPendingListPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserProfilePage()),
        );
        break;
    }
  }


  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF246BFF)),
      ),
    );
  }
}
