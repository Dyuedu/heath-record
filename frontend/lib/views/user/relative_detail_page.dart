import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/encounter_model.dart';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/utils/relationship_formatter.dart';
import 'package:frontend/views/user/encounter_detail_page.dart';
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
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeDetailViewModel>().loadHistory(widget.profileId);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelativeDetailViewModel>();
    final bool isActiveProfile = vm.activeProfileId == widget.profileId;
    final RelativeHistoryModel? history = isActiveProfile ? vm.history : null;
    final allEncounters = history?.encounters ?? const <EncounterModel>[];
    final encounterCount = allEncounters.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context, history),
            Expanded(
              child: vm.isLoading && history == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => vm.refresh(widget.profileId),
                      child: _buildContent(history, encounterCount),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, RelativeHistoryModel? history) {
    final title = (history?.relativeName.trim().isNotEmpty ?? false)
        ? history!.relativeName.trim()
        : widget.relativeName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1F2D3D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildContent(RelativeHistoryModel? history, int encounterCount) {
    if (history == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: const [
          SizedBox(height: 24),
          Text(
            'Chưa có dữ liệu hồ sơ. Kéo xuống để thử tải lại.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final encounters = List<EncounterModel>.from(history.encounters)
      ..sort((a, b) {
        final aTime = a.datetimeEnd ?? a.datetimeStart;
        final bTime = b.datetimeEnd ?? b.datetimeStart;
        if (aTime == null && bTime == null) {
          return 0;
        }
        if (aTime == null) {
          return 1;
        }
        if (bTime == null) {
          return -1;
        }
        return bTime.compareTo(aTime);
      });

    final filteredEncounters = encounters
        .where((encounter) => _matchesSearch(encounter, _searchQuery))
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildPatientHeader(history),
        const SizedBox(height: 14),
        _buildSearchBar(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TIẾN TRÌNH ĐIỀU TRỊ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4A4A4A), letterSpacing: 0.5),
            ),
            Text(
              "$encounterCount bệnh án đã lưu",
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredEncounters.isEmpty)
          const Text(
            'Không tìm thấy đợt khám phù hợp.',
            style: TextStyle(color: Colors.grey),
          )
        else
          ...filteredEncounters.map((e) => _buildEncounterCard(history, e)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo tiêu đề, tag, bác sĩ...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildPatientHeader(RelativeHistoryModel? history) {
    final name = history?.relativeName.trim().isNotEmpty == true
        ? history!.relativeName.trim()
        : widget.relativeName;
    final relationship = formatRelationshipLabel(history?.relationship ?? '');
    final dob = _safeText(history?.dateOfBirth);
    final avatarUrl = (history?.avatarUrl ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          avatarUrl.isEmpty
              ? const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFDDE3FF),
                  child: Icon(Icons.person, size: 32, color: Color(0xFF246BFF)),
                )
              : CircleAvatar(radius: 32, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1F2D3D))),
                const SizedBox(height: 2),
                Text("Quan hệ: $relationship", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                _buildBadge(dob),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFCCF9E1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Color(0xFF00BD6B), fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildEncounterCard(RelativeHistoryModel history, EncounterModel encounter) {
    final tags = _collectEncounterTags(encounter);
    final subtitle = _buildEncounterSubtitle(encounter);
    final doctors = _collectEncounterDoctors(encounter);
    final doctorLabel = doctors.isEmpty ? 'Chưa rõ bác sĩ' : doctors.join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EncounterDetailPage(
                relativeName: history.relativeName,
                encounter: encounter,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(encounter.datetimeStart),
                      style: const TextStyle(
                        color: Color(0xFF246BFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _safeText(encounter.title),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF2D3238),
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoChip(
                Icons.medical_services_outlined,
                subtitle,
              ),
              const SizedBox(height: 8),
              _buildInfoChip(
                Icons.person_outline,
                doctorLabel,
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map(_buildTag).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w500)),
    );
  }

  List<String> _collectEncounterTags(EncounterModel encounter) {
    final values = <String>{};

    final encounterTag = (encounter.tag ?? '').trim();
    if (encounterTag.isNotEmpty) {
      values.add(encounterTag);
    }

    for (final tag in encounter.tagNames) {
      final clean = tag.trim();
      if (clean.isNotEmpty) {
        values.add(clean);
      }
    }

    for (final diagnostic in encounter.diagnostics) {
      final tag = (diagnostic.tag ?? '').trim();
      if (tag.isNotEmpty) {
        values.add(tag);
      }
      for (final childTag in diagnostic.tagNames) {
        final clean = childTag.trim();
        if (clean.isNotEmpty) {
          values.add(clean);
        }
      }
    }

    return values.toList();
  }

  List<String> _collectEncounterDoctors(EncounterModel encounter) {
    final values = <String>{};
    for (final diagnostic in encounter.diagnostics) {
      final doctor = (diagnostic.doctor ?? '').trim();
      if (doctor.isNotEmpty) {
        values.add(doctor);
      }
    }
    return values.toList();
  }

  bool _matchesSearch(EncounterModel encounter, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    final title = encounter.title.toLowerCase();
    if (title.contains(normalized)) {
      return true;
    }

    final tags = _collectEncounterTags(encounter)
        .map((e) => e.toLowerCase())
        .toList();
    if (tags.any((e) => e.contains(normalized))) {
      return true;
    }

    final doctors = _collectEncounterDoctors(encounter)
        .map((e) => e.toLowerCase())
        .toList();
    if (doctors.any((e) => e.contains(normalized))) {
      return true;
    }

    return false;
  }

  String _buildEncounterSubtitle(EncounterModel encounter) {
    final hospital = _safeText(encounter.hospitalName);
    return '${_formatDate(encounter.datetimeStart)} • $hospital';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Chưa rõ thời gian';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _safeText(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? 'Không có' : text;
  }
}