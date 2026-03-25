import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/relationship_formatter.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/user/add_profile_page.dart';
import 'package:frontend/views/user/relative_detail_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primaryBlue = Color(0xFF246BFF);
  static const Color _textMain = Color(0xFF1F2A44);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _bgPage = Color(0xFFF7F9FC);
  static const Color _onlineDot = Color(0xFF22C55E);

  String? _lastOverviewError;
  String? _lastFamilyError;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadOverview();
    });
  }

  Future<void> _handleRefresh() {
    return context.read<ProfileViewModel>().loadOverview();
  }

  // ── Helpers ──────────────────────────────────────────────

  String _formatDateOfBirth(String? dob) {
    final trimmed = (dob ?? '').trim();
    if (trimmed.isEmpty) return 'Chưa cập nhật';
    try {
      if (trimmed.contains('-') && trimmed.length >= 10) {
        final parts = trimmed.split('-');
        if (parts.length >= 3) {
          return '${parts[2].substring(0, 2)}/${parts[1]}/${parts[0]}';
        }
      }
      return trimmed;
    } catch (_) {
      return trimmed;
    }
  }

  int? _calculateAge(String? dob) {
    if (dob == null || dob.trim().isEmpty) return null;
    try {
      DateTime? birth;
      if (dob.contains('-') && dob.length >= 10) {
        birth = DateTime.tryParse(dob);
      }
      if (birth == null) return null;
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age >= 0 ? age : null;
    } catch (_) {
      return null;
    }
  }

  List<Relative> _sortedProfiles(List<Relative> profiles) {
    final sorted = List<Relative>.from(profiles);
    sorted.sort((a, b) {
      final nameA = a.name.toLowerCase();
      final nameB = b.name.toLowerCase();
      return _sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });
    return sorted;
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    // Error handling
    final overviewError = vm.errorMessage;
    if (overviewError != null && overviewError != _lastOverviewError) {
      _lastOverviewError = overviewError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppNotifier.error(context, overviewError);
      });
    } else if (overviewError == null) {
      _lastOverviewError = null;
    }

    final familyError = vm.familyErrorMessage;
    if (familyError != null && familyError != _lastFamilyError) {
      _lastFamilyError = familyError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppNotifier.error(context, familyError);
      });
    } else if (familyError == null) {
      _lastFamilyError = null;
    }

    final List<Relative> allMembers = List.from(vm.familyProfiles);

    final sortedMembers = _sortedProfiles(allMembers);
    final memberCount = sortedMembers.length;

    return Scaffold(
      backgroundColor: _bgPage,
      bottomNavigationBar: const CustomBottomNav(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Hồ sơ gia đình',
          style: TextStyle(color: _textMain, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProfile,
        backgroundColor: _primaryBlue,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: _primaryBlue,
          child: vm.isLoading && allMembers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _buildSummaryCard(sortedMembers, memberCount),
                    const SizedBox(height: 24),
                    _buildSectionHeader(memberCount),
                    const SizedBox(height: 12),
                    if (memberCount == 0)
                      _buildEmptyState()
                    else
                      ...sortedMembers.map((m) => _buildMemberCard(m)),
                    const SizedBox(height: 32),
                    _buildFooter(),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────

  Widget _buildSummaryCard(List<Relative> members, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_outlined, color: _primaryBlue, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THÀNH VIÊN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count người',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textMain,
                  ),
                ),
              ],
            ),
          ),
          _buildAvatarStack(members),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(List<Relative> members) {
    const maxShow = 3;
    final show = members.take(maxShow).toList();
    final extra = members.length - maxShow;

    return SizedBox(
      width: (show.length * 28.0) + (extra > 0 ? 32 : 0) + 4,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < show.length; i++)
            Positioned(
              left: i * 28.0,
              child: _buildSmallAvatar(show[i].avatarUrl, 18),
            ),
          if (extra > 0)
            Positioned(
              left: show.length * 28.0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _primaryBlue,
                child: Text(
                  '+$extra',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar(String? url, double radius) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFDDE3FF),
        backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
        child: (url == null || url.isEmpty) ? Icon(Icons.person, size: radius, color: _primaryBlue) : null,
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────

  Widget _buildSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textMain),
            children: [
              const TextSpan(text: 'Danh sách thành viên  '),
              TextSpan(
                text: '$count',
                style: const TextStyle(color: _primaryBlue, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _sortAscending = !_sortAscending),
          child: Row(
            children: [
              Text(
                'Sắp xếp',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 16,
                color: _primaryBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Member Card ──────────────────────────────────────────

  Widget _buildMemberCard(Relative member) {
    final dobFormatted = _formatDateOfBirth(member.dateOfBirth);
    final age = _calculateAge(member.dateOfBirth);
    final isSelf = member.relationship.toLowerCase() == 'me';
    final relationLabel = formatRelationshipLabel(member.relationship);

    return GestureDetector(
      onTap: () {
        final pid = member.profileId;
        if (pid == null || pid.isEmpty) {
          AppNotifier.info(context, 'Hồ sơ này chưa có thông tin chi tiết.');
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RelativeDetailPage(relativeName: member.name, profileId: pid),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFDDE3FF),
                  backgroundImage: (member.avatarUrl != null && member.avatarUrl!.isNotEmpty)
                      ? NetworkImage(member.avatarUrl!)
                      : null,
                  child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: _primaryBlue, size: 24)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _onlineDot,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _textMain,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRelationshipBadge(relationLabel, isSelf),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: _textMuted),
                      const SizedBox(width: 5),
                      Text(
                        dobFormatted,
                        style: const TextStyle(fontSize: 12.5, color: _textMuted),
                      ),
                      if (age != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          '$age tuổi',
                          style: const TextStyle(fontSize: 12.5, color: _textMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipBadge(String label, bool isSelf) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSelf ? _primaryBlue.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isSelf ? _primaryBlue : _textMuted,
        ),
      ),
    );
  }

  // ── Empty & Footer ───────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.family_restroom_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'Chưa có thành viên nào.\nHãy thêm người thân vào hồ sơ gia đình!',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textMuted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return Column(
      children: [
        Icon(Icons.link_outlined, size: 28, color: Colors.grey.shade300),
        const SizedBox(height: 6),
        Text(
          'Cập nhật lần cuối: $dateStr',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  // ── Navigation ───────────────────────────────────────────

  Future<void> _openAddProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProfilePage()),
    );

    if (!mounted) return;
    await context.read<ProfileViewModel>().reloadFamilyProfiles();
  }
}
