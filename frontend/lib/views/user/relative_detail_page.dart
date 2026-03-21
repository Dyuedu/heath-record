import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/diagnostic_model.dart';
import 'package:frontend/data/models/record/encounter_model.dart';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/viewmodels/relative_detail_viewmodel.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeDetailViewModel>().loadHistory(widget.profileId);
    });
  }

  Future<void> _handleRefresh() {
    return context.read<RelativeDetailViewModel>().refresh(widget.profileId);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelativeDetailViewModel>();
    final bool isActiveProfile = vm.activeProfileId == widget.profileId;
    final RelativeHistoryModel? history = isActiveProfile ? vm.history : null;
    final String? errorMessage = isActiveProfile ? vm.errorMessage : null;
    final bool showGlobalLoading =
        vm.isLoading && (history == null || !isActiveProfile);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          widget.relativeName,
          style: const TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF246BFF),
        backgroundColor: Colors.white,
        onRefresh: _handleRefresh,
        child: _buildBody(
          context,
          history,
          errorMessage,
          showGlobalLoading,
          vm.isLoading && history != null,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RelativeHistoryModel? history,
    String? errorMessage,
    bool showGlobalLoading,
    bool showInlineLoading,
  ) {
    if (showGlobalLoading && history == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [_buildErrorState(errorMessage)],
      );
    }

    if (history == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [_buildEmptyState()],
      );
    }

    final encounters = history.encounters;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _buildRelativeHeader(history, showInlineLoading),
        const SizedBox(height: 16),
        if (encounters.isEmpty)
          _buildEmptyState()
        else
          ...encounters.map(_buildEncounterCard),
      ],
    );
  }

  Widget _buildRelativeHeader(RelativeHistoryModel history, bool loading) {
    final dobText = _formatValue(history.dateOfBirth);
    final avatarUrl = history.avatarUrl.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatarThumb(avatarUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.relativeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2D3D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      history.relationship,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.cake_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ngày sinh: $dobText',
                          style: const TextStyle(
                            color: Color(0xFF5F6368),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tổng số lần khám: ${history.encounters.length}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF4E5D78)),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterCard(EncounterModel encounter) {
    final diagnostics = encounter.diagnostics;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF246BFF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            color: Color(0xFF246BFF),
          ),
        ),
        title: Text(
          encounter.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1F2D3D),
          ),
        ),
        subtitle: Text(
          _buildEncounterSubtitle(encounter),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        children: [
          if ((encounter.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSection(
                title: 'Ghi chú',
                child: Text(
                  encounter.note ?? '',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ),
          if (encounter.tagNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSection(
                title: 'Tags',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: encounter.tagNames
                      .map((tag) => _tagChip(tag))
                      .toList(),
                ),
              ),
            ),
          if (diagnostics.isEmpty)
            _buildEmptyDiagnostics()
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: diagnostics.map(_buildDiagnosticCard).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(DiagnosticModel diagnostic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF246BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  diagnostic.category,
                  style: const TextStyle(
                    color: Color(0xFF246BFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (diagnostic.tag != null && diagnostic.tag!.isNotEmpty)
                Text(
                  '#${diagnostic.tag}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              const Spacer(),
              if (diagnostic.datetimeEnd != null)
                Text(
                  '${diagnostic.datetimeEnd!.day}/${diagnostic.datetimeEnd!.month}/${diagnostic.datetimeEnd!.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if ((diagnostic.data ?? '').isNotEmpty)
            Text(
              diagnostic.data!,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          if (diagnostic.doctor != null && diagnostic.doctor!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Bác sĩ: ${diagnostic.doctor}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4E5D78)),
              ),
            ),
          if (diagnostic.hospitalName != null &&
              diagnostic.hospitalName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Cơ sở y tế: ${diagnostic.hospitalName}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4E5D78)),
              ),
            ),
          if (diagnostic.tagNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: diagnostic.tagNames.map(_tagChip).toList(),
              ),
            ),
          if (diagnostic.attachmentUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: diagnostic.attachmentUrls
                    .map((url) => _attachmentChip(url))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF246BFF),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildEmptyDiagnostics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chưa có chẩn đoán chi tiết cho lần khám này.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _handleRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF246BFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'Chưa có lần khám nào được lưu lại.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(
          color: Color(0xFF246BFF),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _attachmentChip(String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF26BC9B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 14, color: Color(0xFF26BC9B)),
          const SizedBox(width: 6),
          Text(
            'Tệp đính kèm',
            style: const TextStyle(
              color: Color(0xFF26BC9B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _buildEncounterSubtitle(EncounterModel encounter) {
    final String hospital = (encounter.hospitalName ?? '').isEmpty
        ? 'Cơ sở chưa rõ'
        : encounter.hospitalName!;
    final dateText = encounter.datetimeStart != null
        ? '${encounter.datetimeStart!.day}/${encounter.datetimeStart!.month}/${encounter.datetimeStart!.year}'
        : 'Ngày chưa rõ';
    return '$hospital • $dateText';
  }

  Widget _buildAvatarThumb(String avatarUrl) {
    return avatarUrl.isEmpty
        ? const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFDDE3FF),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE0E0FF),
              child: Icon(Icons.person, color: Color(0xFF246BFF), size: 22),
            ),
          )
        : CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFDDE3FF),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          );
  }

  String _formatValue(String? value) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? 'Chưa cập nhật' : trimmed;
  }
}
