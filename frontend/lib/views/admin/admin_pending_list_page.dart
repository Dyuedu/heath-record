import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/views/admin/admin_bottom_nav.dart';
import 'package:frontend/views/admin/admin_dashboard_page.dart';
import 'package:frontend/views/admin/admin_user_management_page.dart';
import 'package:frontend/views/admin/admin_account_approval_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';

class AdminPendingListPage extends StatefulWidget {
  const AdminPendingListPage({super.key});

  @override
  State<AdminPendingListPage> createState() => _AdminPendingListPageState();
}

class _AdminPendingListPageState extends State<AdminPendingListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _roleFilter = 'Tất cả';
  String _dateFilter = 'Ngày đăng ký';

  static const List<String> _roleOptions = ['Tất cả', 'Bác sĩ', 'Y tá', 'Duyệt viên', 'Kỹ thuật viên'];
  static const List<String> _dateOptions = ['Ngày đăng ký', 'Mới nhất', 'Cũ nhất'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingUsers();
    });
  }

  void _loadPendingUsers() {
    String? role = _roleFilter == 'Tất cả' ? null : _roleFilter;
    String? search = _searchController.text.trim();
    if (search.isEmpty) search = null;

    context.read<AdminViewModel>().loadPendingUsers(search: search, role: role);
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
          'Quản lý Chờ duyệt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2A44),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 24),
            color: const Color(0xFF374151),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              height: 46,
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
                      onSubmitted: (_) => _loadPendingUsers(),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên, email...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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

          // Filters row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Vai trò: $_roleFilter',
                  onTap: () => _showFilterMenu(
                    options: _roleOptions,
                    current: _roleFilter,
                    onSelect: (v) {
                      setState(() => _roleFilter = v);
                      _loadPendingUsers();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _dateFilter,
                  onTap: () => _showFilterMenu(
                    options: _dateOptions,
                    current: _dateFilter,
                    onSelect: (v) => setState(() => _dateFilter = v),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 18, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Lọc',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body content wrapped in Consumer
          Expanded(
            child: Consumer<AdminViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF246BFF)));
                }

                final users = viewModel.pendingUsers;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            'DANH SÁCH HỒ SƠ (${users.length})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _loadPendingUsers,
                            child: const Text(
                              'Làm mới',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF246BFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                                return _buildPendingCard(users[index]);
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
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }


  Widget _buildFilterChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showFilterMenu({
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option == current;
              return ListTile(
                dense: true,
                title: Text(
                  option,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF246BFF) : const Color(0xFF374151),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: Color(0xFF246BFF), size: 20)
                    : null,
                onTap: () {
                  onSelect(option);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPendingCard(UserProfileModel user) {
    // Generate some deterministic colors from name length roughly
    final colorVal = user.fullName.length;
    final roleColor = colorVal % 2 == 0 ? const Color(0xFF246BFF) : const Color(0xFF10B981);
    final avatarColor = colorVal % 3 == 0 ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminAccountApprovalPage(user: user)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // User info row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor.withOpacity(0.15),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1F2A44),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.role,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Registration date
            Row(
              children: [
                const SizedBox(width: 56), // align with content after avatar
                Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Text(
                  'Đăng ký: ${user.createdAt ?? "Không rõ"}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                const SizedBox(width: 56),
                // Từ chối
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _onRejectTapped(user.id),
                    icon: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade500),
                    label: Text(
                      'Từ chối',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Duyệt
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _onApproveTapped(user.id),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text(
                      'Duyệt',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 36),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Không có hồ sơ chờ duyệt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tất cả hồ sơ đã được xử lý.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminUserManagementPage()),
        );
        break;
      case 2:
        break; // Already here
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserProfilePage()),
        );
        break;
    }
  }
  Future<void> _onApproveTapped(String id) async {
    _showLoadingOverlay(context);
    final success = await context.read<AdminViewModel>().approveUser(id);
    if (mounted) Navigator.pop(context); // close loader
    if (success && mounted) {
      context.read<AdminViewModel>().loadDashboardStats(); // update dashboard count
    }
  }

  Future<void> _onRejectTapped(String id) async {
    _showLoadingOverlay(context);
    final success = await context.read<AdminViewModel>().rejectUser(id);
    if (mounted) Navigator.pop(context); // close loader
    if (success && mounted) {
      context.read<AdminViewModel>().loadDashboardStats();
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

