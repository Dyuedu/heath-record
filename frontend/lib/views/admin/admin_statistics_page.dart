import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/views/admin/admin_bottom_nav.dart';
import 'package:frontend/views/admin/admin_dashboard_page.dart';
import 'package:frontend/views/admin/admin_user_management_page.dart';
import 'package:frontend/views/admin/admin_profile_page.dart';

class AdminStatisticsPage extends StatefulWidget {
  const AdminStatisticsPage({super.key});

  @override
  State<AdminStatisticsPage> createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage> {
  final List<_PeriodOption> _periods = const [
    _PeriodOption('day', 'Ngày'),
    _PeriodOption('week', 'Tuần'),
    _PeriodOption('month', 'Tháng'),
    _PeriodOption('year', 'Năm'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AdminViewModel>();
      vm.loadUserStats();
      vm.loadRecordStatsSeparate();
    });
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return; // Already here
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminUserManagementPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Consumer<AdminViewModel>(
          builder: (context, vm, _) {
            return RefreshIndicator(
              onRefresh: () async {
                final vm = context.read<AdminViewModel>();
                await vm.loadUserStats();
                await vm.loadRecordStatsSeparate();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, vm)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow(vm),
                          const SizedBox(height: 24),
                          // Title row
                          const Text(
                            'Thống kê theo thời gian',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2A44),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildChartCard(
                            context: context, 
                            vm: vm, 
                            title: 'Biểu đồ người dùng mới', 
                            dataKey: 'userChartData', 
                            chartType: vm.userChartType,
                            onToggle: (type) => vm.setUserChartType(type),
                            gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                            periodChips: _buildPeriodChips(vm, 'user'),
                            onPeriodChange: (period) => vm.loadUserStats(period: period),
                            stats: vm.userStats,
                          ),
                          const SizedBox(height: 24),
                          
                          _buildChartCard(
                            context: context, 
                            vm: vm, 
                            title: 'Biểu đồ bệnh án', 
                            dataKey: 'recordChartData', 
                            chartType: vm.recordChartType,
                            onToggle: (type) => vm.setRecordChartType(type),
                            gradient: const [Color(0xFF246BFF), Color(0xFF5B8DEF)],
                            periodChips: _buildPeriodChips(vm, 'record'),
                            onPeriodChange: (period) => vm.loadRecordStatsSeparate(period: period),
                            stats: vm.recordStats,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AdminViewModel vm) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: const Color(0xFF1F2A44),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
            );
          }
        },
      ),
      title: const Text(
        'Thống kê',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2A44),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(AdminViewModel vm) {
    final stats = vm.recordStats;
    final totalRecords = stats?['totalRecords'] ?? 0;
    final totalUsers = stats?['totalUsers'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.description_rounded,
            iconBgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
            label: 'TỔNG BỆNH ÁN',
            value: totalRecords.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.people_alt_rounded,
            iconBgColor: const Color(0xFFE8F1FF),
            iconColor: const Color(0xFF246BFF),
            label: 'TỔNG NGƯỜI DÙNG',
            value: totalUsers.toString(),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2A44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required BuildContext context, 
    required AdminViewModel vm,
    required String title,
    required String dataKey,
    required String chartType,
    required Function(String) onToggle,
    required List<Color> gradient,
    required Widget periodChips,
    required Function(String) onPeriodChange,
    required Map<String, dynamic>? stats,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2A44),
                  ),
                ),
              ),
              _chartToggle(chartType, onToggle),
            ],
          ),
          const SizedBox(height: 16),
          periodChips,
          const SizedBox(height: 20),

          // Chart or loading/empty
          SizedBox(
            height: 220,
            child: _buildChart(vm, dataKey, chartType, gradient, stats, dataKey == 'userChartData'),
          ),
        ],
      ),
    );
  }

  Widget _chartToggle(String currentType, Function(String) onToggle) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _toggleBtn(
            label: 'Cột',
            icon: Icons.bar_chart_rounded,
            selected: currentType == 'bar',
            onTap: () => onToggle('bar'),
          ),
          _toggleBtn(
            label: 'Đường',
            icon: Icons.show_chart_rounded,
            selected: currentType == 'line',
            onTap: () => onToggle('line'),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF246BFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChips(AdminViewModel vm, String type) {
    final currentPeriod = type == 'user' ? vm.userPeriod : vm.recordPeriod;
    final onTap = type == 'user' ? (String p) => vm.loadUserStats(period: p) : (String p) => vm.loadRecordStatsSeparate(period: p);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((p) {
          final selected = currentPeriod == p.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(p.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF246BFF) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(AdminViewModel vm, String dataKey, String chartType, List<Color> gradient, Map<String, dynamic>? stats, bool isUserChart) {
    final isLoading = isUserChart ? vm.userLoading : vm.recordLoading;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: gradient.first),
      );
    }

    final rawData = stats?[dataKey];
    if (rawData == null || (rawData as List).isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              'Không có dữ liệu trong khoảng thời gian này',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final List<Map<String, dynamic>> chartData =
        (rawData).cast<Map<String, dynamic>>();

    return chartType == 'bar'
        ? _buildBarChart(chartData, gradient)
        : _buildLineChart(chartData, gradient);
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, List<Color> gradient) {
    final maxY = data.map((d) => (d['count'] as num).toDouble()).fold(0.0, (a, b) => a > b ? a : b);
    final barGroups = data.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (e.value['count'] as num).toDouble(),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2 + 1,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4).clamp(1, double.infinity),
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42, // increased for angled text
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  angle: -0.5, // ~ -30 degrees to prevent overlap
                  child: Text(
                    data[idx]['label'] as String,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF)),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1F2A44),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x]['label']}\n${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data, List<Color> gradient) {
    final maxY = data.map((d) => (d['count'] as num).toDouble()).fold(0.0, (a, b) => a > b ? a : b);
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['count'] as num).toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        maxY: maxY * 1.2 + 1,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            gradient: LinearGradient(
              colors: gradient,
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  gradient.first.withOpacity(0.15),
                  gradient.first.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: gradient.first,
              ),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4).clamp(1, double.infinity),
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  angle: -0.5,
                  child: Text(
                    data[idx]['label'] as String,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF)),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1F2A44),
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.spotIndex;
              return LineTooltipItem(
                '${data[idx]['label']}\n${s.y.toInt()}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PeriodOption {
  final String value;
  final String label;
  const _PeriodOption(this.value, this.label);
}
