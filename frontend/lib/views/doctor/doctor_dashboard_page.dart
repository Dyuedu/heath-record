import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/doctor_ui_helpers.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:frontend/viewmodels/notification_viewmodel.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final profile = profileVm.profile;
    final doctorName = profile?.fullName ?? 'Doctor';
    final avatarUrl = profile?.avatarUrl.isNotEmpty == true
        ? profile!.avatarUrl
        : 'https://via.placeholder.com/150';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, doctorName, avatarUrl),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildActionGrid(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String doctorName,
    String avatarUrl,
  ) {
    final greeting = _greetingMessage();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: DoctorUIHelpers.headerGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: DoctorUIHelpers.softShadow(),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _handleMenuSelection(context, value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'settings', child: Text('Settings')),
                  PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Today', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 6),
                    Text(
                      '3 Appointments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              DoctorUIHelpers.gradientAvatar(avatarUrl, size: 90),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'icon': Icons.event_available, 'value': '12', 'label': "Today's Appts"},
      {'icon': Icons.pending_actions, 'value': '5', 'label': 'Pending Records'},
      {'icon': Icons.groups_rounded, 'value': '128', 'label': 'Total Patients'},
    ];
    return Row(
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == stats.length - 1 ? 0 : 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: DoctorUIHelpers.softShadow(blur: 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(stat['icon'] as IconData, color: AppTheme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.bodyTextColor,
                    ),
                  ),
                  Text(
                    stat['label'] as String,
                    style: const TextStyle(color: AppTheme.captionTextColor),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {
        'title': 'Create Record',
        'icon': Icons.note_add_rounded,
        'onTap': (BuildContext context) =>
            _showComingSoon(context, 'Vui lòng tạo hồ sơ từ trang Home > Hồ sơ mới.'),
      },
      {
        'title': 'View Patients',
        'icon': Icons.people_alt_rounded,
        'onTap': (BuildContext context) =>
            _showComingSoon(context, 'Patient manager coming soon.'),
      },
      {
        'title': 'Schedule',
        'icon': Icons.calendar_month,
        'onTap': (BuildContext context) =>
            _showComingSoon(context, 'Connected calendar coming soon.'),
      },
      {
        'title': 'My Profile',
        'icon': Icons.person_outline,
        'onTap': (BuildContext context) =>
            _showComingSoon(context, 'Profile editing coming soon.'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () =>
              (action['onTap'] as void Function(BuildContext))(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: DoctorUIHelpers.softShadow(blur: 18),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  action['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.bodyTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap to continue',
                  style: TextStyle(
                    color: AppTheme.captionTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'title': 'Dermatitis follow up',
        'patient': 'Sophia Reed',
        'time': '09:20 AM',
      },
      {
        'title': 'New biopsy uploaded',
        'patient': 'Alan Shaw',
        'time': '11:05 AM',
      },
      {
        'title': 'Hormone results ready',
        'patient': 'Evelyn Park',
        'time': '02:40 PM',
      },
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: DoctorUIHelpers.softShadow(blur: 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.bodyTextColor,
                  ),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View all')),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.bodyTextColor,
                          ),
                        ),
                        Text(
                          activity['patient'] as String,
                          style: const TextStyle(
                            color: AppTheme.captionTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity['time'] as String,
                    style: const TextStyle(color: AppTheme.captionTextColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'logout') {
      _logout(context);
    } else if (value == 'settings') {
      _showComingSoon(context, 'Settings screen coming soon.');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (context.mounted) {
      context.read<ProfileViewModel>().clearSessionData();
      context.read<NotificationViewModel>().clearSessionData();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _showComingSoon(BuildContext context, String message) {
    AppNotifier.info(context, message);
  }
}
