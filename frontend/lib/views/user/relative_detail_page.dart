import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/encounter_model.dart';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/relationship_formatter.dart';
import 'package:frontend/views/user/encounter_detail_page.dart';
import 'package:frontend/views/user/relative_profile_edit_page.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/relative_detail_viewmodel.dart';

class RelativeDetailPage extends StatefulWidget {
  final String relativeName;
  final String profileId;

  const RelativeDetailPage({
    super.key,
    required this.relativeName,
    required this.profileId,
  });

  @override
  State<RelativeDetailPage> createState() => _RelativeDetailPageState();
}

class _RelativeDetailPageState extends State<RelativeDetailPage> {
  static const Color _primaryBlue = Color(0xFF246BFF);
  static const Color _textMain = Color(0xFF1F2A44);
  static const Color _textMuted = Color(0xFF6B7280);

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final _vietnameseMonths = [
    '', 'THÁNG 01', 'THÁNG 02', 'THÁNG 03', 'THÁNG 04', 'THÁNG 05', 'THÁNG 06',
    'THÁNG 07', 'THÁNG 08', 'THÁNG 09', 'THÁNG 10', 'THÁNG 11', 'THÁNG 12',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RelativeDetailViewModel>();
      vm.loadHistory(widget.profileId);
      vm.loadRelativeProfile(widget.profileId);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────

  String _formatTimelineDate(DateTime? date) {
    if (date == null) return 'Chưa rõ';
    return '${date.day.toString().padLeft(2, '0')} ${_vietnameseMonths[date.month]}, ${date.year}';
  }

  String _safeText(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? 'Không có' : text;
  }

  String _mapTypeLabel(String? type) {
    if (type == null) return '';
    switch (type.toUpperCase()) {
      case 'INITIAL': return 'Khám mới';
      case 'FOLLOW_UP': return 'Tái khám';
      case 'ROUTINE_BACKUP': return 'Khám định kỳ';
      default: return type;
    }
  }

  List<String> _collectEncounterTags(EncounterModel encounter) {
    final values = <String>{};
    final encounterTag = (encounter.tag ?? '').trim();
    if (encounterTag.isNotEmpty) values.add(encounterTag);
    for (final tag in encounter.tagNames) {
      final clean = tag.trim();
      if (clean.isNotEmpty) values.add(clean);
    }
    for (final diagnostic in encounter.diagnostics) {
      final tag = (diagnostic.tag ?? '').trim();
      if (tag.isNotEmpty) values.add(tag);
      for (final childTag in diagnostic.tagNames) {
        final clean = childTag.trim();
        if (clean.isNotEmpty) values.add(clean);
      }
    }
    return values.toList();
  }

  List<String> _collectEncounterDoctors(EncounterModel encounter) {
    final values = <String>{};
    for (final diagnostic in encounter.diagnostics) {
      final doctor = (diagnostic.doctor ?? '').trim();
      if (doctor.isNotEmpty) values.add(doctor);
    }
    return values.toList();
  }

  bool _matchesSearch(EncounterModel encounter, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    if (encounter.title.toLowerCase().contains(normalized)) return true;
    final tags = _collectEncounterTags(encounter).map((e) => e.toLowerCase());
    if (tags.any((e) => e.contains(normalized))) return true;
    final doctors = _collectEncounterDoctors(encounter).map((e) => e.toLowerCase());
    if (doctors.any((e) => e.contains(normalized))) return true;
    for (final diag in encounter.diagnostics) {
      if (diag.category.toLowerCase().contains(normalized)) return true;
    }
    return false;
  }

  // ── Build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelativeDetailViewModel>();
    final bool isActiveProfile = vm.activeProfileId == widget.profileId;
    final RelativeHistoryModel? history = isActiveProfile ? vm.history : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin',
          style: TextStyle(color: _textMain, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_note_rounded, color: _primaryBlue),
            tooltip: 'Cập nhật hồ sơ',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: vm.isLoading && history == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => vm.refresh(widget.profileId),
              color: _primaryBlue,
              child: _buildBody(history),
            ),
    );
  }

  Widget _buildBody(RelativeHistoryModel? history) {
    if (history == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Center(child: Text('Chưa có dữ liệu. Kéo xuống để tải lại.', style: TextStyle(color: Colors.grey))),
        ],
      );
    }

    final encounters = List<EncounterModel>.from(history.encounters)
      ..sort((a, b) {
        final aTime = a.datetimeEnd ?? a.datetimeStart;
        final bTime = b.datetimeEnd ?? b.datetimeStart;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

    final filtered = encounters
      .where((e) => _matchesSearch(e, _searchQuery))
        .toList();
    final encounterCount = encounters.length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // Search bar
        _buildSearchBar(),
        const SizedBox(height: 20),

        // Patient info card
        _buildPatientCard(history),
        const SizedBox(height: 24),

        // Timeline header
        _buildTimelineHeader(encounterCount),
        const SizedBox(height: 16),

        // Timeline
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('Không tìm thấy bệnh án phù hợp.', style: TextStyle(color: Colors.grey))),
          )
        else
          ...filtered.asMap().entries.map((entry) => _buildTimelineItem(history, entry.value, entry.key == filtered.length - 1)),

        // Footer
        const SizedBox(height: 24),
        _buildFooter(),
      ],
    );
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RelativeProfileEditPage(profileId: widget.profileId),
      ),
    );

    if (!mounted || result != true) {
      return;
    }

    final vm = context.read<RelativeDetailViewModel>();
    await vm.refresh(widget.profileId);
    await vm.loadRelativeProfile(widget.profileId);
    if (!mounted) return;
    AppNotifier.success(context, 'Đã cập nhật hồ sơ người thân');
  }

  // ── Search Bar ───────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Tìm theo chẩn đoán, bác sĩ...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Patient Card ─────────────────────────────────────

  Widget _buildPatientCard(RelativeHistoryModel history) {
    final name = history.relativeName.trim().isNotEmpty ? history.relativeName.trim() : widget.relativeName;
    final avatarUrl = history.avatarUrl.trim();
    final dobFormatted = _formatDob(history.dateOfBirth);
    final age = _calculateAge(history.dateOfBirth);

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFDDE3FF),
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty ? const Icon(Icons.person, color: _primaryBlue, size: 24) : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textMain)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: _textMuted),
                  const SizedBox(width: 5),
                  Text(dobFormatted, style: const TextStyle(fontSize: 12, color: _textMuted)),
                  if (age != null) ...[
                    const SizedBox(width: 10),
                    Text('$age tuổi', style: const TextStyle(fontSize: 12, color: _textMuted, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFFD6A5)),
                    ),
                    child: Text(
                      formatRelationshipLabel(history.relationship),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE67E22)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDob(String? dob) {
    final trimmed = (dob ?? '').trim();
    if (trimmed.isEmpty) return 'Chưa cập nhật';
    try {
      if (trimmed.contains('-') && trimmed.length >= 10) {
        final parts = trimmed.split('-');
        if (parts.length >= 3) return '${parts[2].substring(0, 2)}/${parts[1]}/${parts[0]}';
      }
      return trimmed;
    } catch (_) { return trimmed; }
  }

  int? _calculateAge(String? dob) {
    if (dob == null || dob.trim().isEmpty) return null;
    try {
      final birth = DateTime.tryParse(dob);
      if (birth == null) return null;
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) age--;
      return age >= 0 ? age : null;
    } catch (_) { return null; }
  }

  // ── Timeline Header ──────────────────────────────────

  Widget _buildTimelineHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'TIẾN TRÌNH ĐIỀU TRỊ',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _textMain, letterSpacing: 0.8),
        ),
        Text(
          '$count bệnh án đã lưu',
          style: const TextStyle(fontSize: 11, color: _textMuted, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // ── Timeline Item ────────────────────────────────────

  Widget _buildTimelineItem(RelativeHistoryModel history, EncounterModel encounter, bool isLast) {
    final doctors = _collectEncounterDoctors(encounter);
    final doctorLabel = doctors.isNotEmpty ? 'BS. ${doctors.first}' : '';
    final tags = _collectEncounterTags(encounter);

    // Get first diagnostic's category and type
    String category = '';
    String typeLabel = '';
    if (encounter.diagnostics.isNotEmpty) {
      final firstDiag = encounter.diagnostics.first;
      category = firstDiag.category.trim();
      typeLabel = _mapTypeLabel(firstDiag.type);
    }

    return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EncounterDetailPage(
                    relativeName: history.relativeName,
                    encounter: encounter,
                  ),
                ));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date + chevron
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimelineDate(encounter.datetimeEnd ?? encounter.datetimeStart),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _primaryBlue),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFD1D5DB)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title (diagnosis summary)
                    Text(
                      _safeText(encounter.title),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textMain, height: 1.4),
                    ),
                    const SizedBox(height: 12),

                    // Doctor
                    if (doctorLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 14, color: _textMuted),
                            const SizedBox(width: 5),
                            Text(doctorLabel, style: const TextStyle(fontSize: 12, color: _textMuted)),
                          ],
                        ),
                      ),

                    // Category
                    if (category.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.local_hospital_outlined, size: 14, color: _textMuted),
                            const SizedBox(width: 5),
                            Text(category, style: const TextStyle(fontSize: 12, color: _textMuted)),
                          ],
                        ),
                      ),

                    // Tags row
                    if (tags.isNotEmpty || typeLabel.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (typeLabel.isNotEmpty)
                            _buildChip(typeLabel, const Color(0xFFEEF2FF), _primaryBlue),
                          ...tags.map((t) => _buildChip(t, const Color(0xFFF3F4F6), _textMuted)),
                        ],
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
    );
  }

  // ── Footer ───────────────────────────────────────────

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.link_outlined, size: 24, color: Colors.grey.shade300),
          const SizedBox(height: 4),
          Text(
            'Kết thúc lịch sử',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}