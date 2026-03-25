import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/views/admin/admin_bottom_nav.dart';
import 'package:frontend/views/admin/admin_user_management_page.dart';
import 'package:frontend/views/admin/admin_pending_list_page.dart';
import 'package:frontend/views/admin/admin_statistics_page.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/views/admin/admin_tag_management_page.dart';
import 'package:frontend/views/admin/admin_hospital_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AdminViewModel>();
      vm.loadDashboardStats();
      vm.loadRecordStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Consumer<AdminViewModel>(
          builder: (context, viewModel, child) {
            final stats = viewModel.dashboardStats;
            final pendingCount = stats?['pendingApprovals'] ?? 0;
            final userCount = stats?['totalUsers'] ?? 0;
            final recordsCount = stats?['newRecordsThisMonth'] ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  // Greeting + alert
                  _buildGreetingSection(pendingCount),
                  const SizedBox(height: 20),

                  // Stat cards row
                  _buildStatCardsRow(userCount, pendingCount),
                  const SizedBox(height: 16),

                   // Monthly records stat
                  _buildMonthlyRecordCard(recordsCount),
                  const SizedBox(height: 20),

                  // Mini chart preview
                  _buildMiniChartPreview(viewModel),
                  const SizedBox(height: 28),

                  // Quick shortcuts
                  _buildShortcutsSection(context),
                  const SizedBox(height: 28),

                  // Recent activity
                  _buildRecentActivity(context),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break; // Already on dashboard
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminUserManagementPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminPendingListPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminStatisticsPage()),
        );
        break;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF246BFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2A44),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            _showLogoutDialog(context, context.read<AuthViewModel>());
          },
          child: _iconCircle(Icons.logout_rounded, badge: false),
        ),
      ],
    );
  }

  Widget _iconCircle(IconData icon, {bool badge = false}) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: const Color(0xFF374151), size: 22),
        ),
        if (badge)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGreetingSection(int pendingCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF246BFF), Color(0xFF5B8DEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF246BFF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chào buổi sáng, Bác sĩ Minh!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hôm nay có $pendingCount tài khoản mới đang chờ bạn phê duyệt.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsRow(int userCount, int pendingCount) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_rounded,
            iconBgColor: const Color(0xFFE8F1FF),
            iconColor: const Color(0xFF246BFF),
            label: 'TỔNG NGƯỜI DÙNG',
            value: userCount.toString(),
            change: '+2%',
            changeColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.hourglass_top_rounded,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFF59E0B),
            label: 'CHỜ DUYỆT',
            value: pendingCount.toString().padLeft(2, '0'),
            change: '+1%',
            changeColor: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required String change,
    required Color changeColor,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2A44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRecordCard(int recordsCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.description_rounded, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BỆNH ÁN MỚI (THÁNG NÀY)',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recordsCount.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChartPreview(AdminViewModel vm) {
    final rawData = vm.recordStats?['chartData'];
    final List<Map<String, dynamic>> chartData =
        rawData != null ? (rawData as List).cast<Map<String, dynamic>>() : [];

    final hasData = chartData.isNotEmpty;
    final maxY = hasData
        ? chartData.map((d) => (d['count'] as num).toDouble()).fold(0.0, (a, b) => a > b ? a : b)
        : 1.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminStatisticsPage()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF246BFF), Color(0xFF5B8DEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF246BFF).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Thống kê bệnh án (12 tháng)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: !hasData
                  ? Center(
                      child: Text(
                        'Chưa có dữ liệu',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        maxY: maxY * 1.3 + 1,
                        barGroups: chartData.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: (e.value['count'] as num).toDouble(),
                                color: Colors.white.withOpacity(0.8),
                                width: 8,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }).toList(),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barTouchData: BarTouchData(enabled: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LỐI TẮT QUẢN LÝ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _shortcutItem(
                icon: Icons.people_alt_rounded,
                label: 'Người dùng',
                subtitle: 'xem và hồ sơ',
                bgColor: const Color(0xFFE8F1FF),
                iconColor: const Color(0xFF246BFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUserManagementPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _shortcutItem(
                icon: Icons.fact_check_rounded,
                label: 'Duyệt hồ sơ',
                subtitle: 'bác sĩ mới & bác sĩ',
                bgColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminPendingListPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _shortcutItem(
                icon: Icons.bar_chart_rounded,
                label: 'Thống kê',
                subtitle: 'bệnh án & biểu đồ',
                bgColor: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminStatisticsPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                          child: _shortcutItem(
                            icon: Icons.local_hospital_rounded,
                            label: 'Bệnh viện',
                            subtitle: 'quản lý danh sách',
                            bgColor: const Color(0xFFECFDF5),
                            iconColor: const Color(0xFF10B981),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminHospitalManagementPage()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _shortcutItem(
                            icon: Icons.local_offer_rounded,
                            label: 'Từ khóa',
                            subtitle: 'quản lý tags',
                            bgColor: const Color(0xFFF0F9FF),
                            iconColor: const Color(0xFF06B6D4),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminTagManagementPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),


          ],
        ),
      ],
    );
  }

  Widget _shortcutItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2A44),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HOẠT ĐỘNG GẦN ĐÂY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF246BFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
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
              _activityItem(
                avatar: 'P',
                avatarColor: const Color(0xFF246BFF),
                title: 'Bs. Phương Thảo',
                action: 'đã phê duyệt',
                target: 'Tài khoản Bs. Nam',
                time: '5 phút trước',
                isFirst: true,
              ),
              _activityDivider(),
              _activityItem(
                avatar: 'A',
                avatarColor: const Color(0xFF10B981),
                title: 'Admin Trung',
                action: 'vừa tạo mới',
                target: 'Khoa Nội tổng quát',
                time: '1 giờ trước',
              ),
              _activityDivider(),
              _activityItem(
                avatar: 'H',
                avatarColor: const Color(0xFFF59E0B),
                title: 'Y tá Hồng',
                action: 'đã cập nhật',
                target: 'Quy trình duyệt thẻ',
                time: '2 giờ trước',
              ),
              _activityDivider(),
              _activityItem(
                avatar: 'P',
                avatarColor: const Color(0xFFEF4444),
                title: 'Bs. Phương Thảo',
                action: 'đã từ chối',
                target: 'Hồ sơ User_9921',
                time: '5 giờ trước',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityDivider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 68);
  }

  Widget _activityItem({
    required String avatar,
    required Color avatarColor,
    required String title,
    required String action,
    required String target,
    required String time,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 12,
        16,
        isLast ? 16 : 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarColor.withOpacity(0.15),
            child: Text(
              avatar,
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' $action '),
                      TextSpan(
                        text: target,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF246BFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Hủy')
          ),
          TextButton(
            onPressed: () async {
              await vm.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const LoginPage()), 
                (route) => false
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
