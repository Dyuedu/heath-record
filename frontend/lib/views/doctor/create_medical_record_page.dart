import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/hospital_response.dart';
import 'package:frontend/data/models/relative_search_response.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/relationship_formatter.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/views/doctor/widgets/diagnostic_card.dart';
import 'package:frontend/views/doctor/widgets/record_section_header.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DiagnosticFormModel {
  TextEditingController categoryController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController dataController = TextEditingController();
  List<File> images = [];
  List<String> tags = [];

  void dispose() {
    categoryController.dispose();
    tagController.dispose();
    dataController.dispose();
  }
}

class CreateMedicalRecordPage extends StatefulWidget {
  final ProfileSearchResponse? initialPatient;

  const CreateMedicalRecordPage({
    super.key,
    this.initialPatient,
  });

  @override
  State<CreateMedicalRecordPage> createState() => _CreateMedicalRecordPageState();
}

class _CreateMedicalRecordPageState extends State<CreateMedicalRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  ProfileSearchResponse? _selectedRelative;
  HospitalResponse? _selectedHospital;
  List<HospitalResponse> _hospitals = [];
  List<ProfileSearchResponse> _relativeOptions = <ProfileSearchResponse>[];

  Timer? _relativeSearchDebounce;
  TextEditingController? _relativeFieldController;
  TextEditingController? _hospitalFieldController;
  String _lastRelativeQuery = '';

  final List<DiagnosticFormModel> _diagnostics = [];
  bool _isLoading = false;

  DateTime? _examDate = DateTime.now();
  String _examType = 'Tái khám';
  bool _isHospitalDropdownOpen = false;

  final Color _primaryBlue = const Color(0xFF246BFF);
  final Color _textMain = const Color(0xFF1F2A44);
  final Color _textMuted = const Color(0xFF6B7280);
  final Color _borderLight = const Color(0xFFF3F4F6);
  final Color _bgLight = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _selectedRelative = widget.initialPatient;
    _diagnostics.add(DiagnosticFormModel());
    _hospitalFieldController = TextEditingController();
    _hospitalFieldController!.addListener(_handleHospitalQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHospitals();
    });
  }

  @override
  void dispose() {
    _relativeSearchDebounce?.cancel();
    _relativeFieldController?.removeListener(_handleRelativeQueryChanged);
    _hospitalFieldController?.removeListener(_handleHospitalQueryChanged);
    _titleController.dispose();
    _noteController.dispose();
    for (final diag in _diagnostics) {
      diag.dispose();
    }
    super.dispose();
  }

  Future<void> _loadHospitals() async {
    try {
      final repository = context.read<RecordRepository>();
      final h = await repository.getHospitals();
      if (mounted) {
        setState(() {
          _hospitals = h;
        });
      }
    } catch (_) {
      // Ignore silently; UI will show empty state.
    }
  }

  void _addDiagnostic() {
    setState(() {
      _diagnostics.add(DiagnosticFormModel());
    });
  }

  void _removeDiagnostic(int index) {
    if (index < 0 || index >= _diagnostics.length) return;
    final removed = _diagnostics.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _removeDiagnosticImage(int diagIndex, int imageIndex) {
    if (diagIndex < 0 || diagIndex >= _diagnostics.length) return;
    final images = _diagnostics[diagIndex].images;
    if (imageIndex < 0 || imageIndex >= images.length) return;
    setState(() {
      images.removeAt(imageIndex);
    });
  }

  Future<void> _pickImages(int index) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _diagnostics[index].images.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  void _handleRelativeQueryChanged() {
    final controller = _relativeFieldController;
    if (controller == null) return;
    final query = controller.text;
    _relativeSearchDebounce?.cancel();

    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _relativeOptions = <ProfileSearchResponse>[];
        _selectedRelative = null;
      });
      return;
    }

    if (_selectedRelative != null &&
        !_equalsIgnoreCase(_selectedRelative!.fullName, query)) {
      setState(() {
        _selectedRelative = null;
      });
    }

    if (_relativeOptions.isNotEmpty) {
      setState(() {
        _relativeOptions = <ProfileSearchResponse>[];
      });
    }

    _relativeSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      _lastRelativeQuery = trimmed;
      _fetchRelativeOptions(trimmed);
    });
  }

  void _handleHospitalQueryChanged() {
    final controller = _hospitalFieldController;
    if (controller == null) return;
    final query = controller.text.trim();
    if (query.isEmpty && _selectedHospital != null) {
      setState(() {
        _selectedHospital = null;
      });
    } else if (_selectedHospital != null &&
        !_equalsIgnoreCase(_selectedHospital!.name, query)) {
      setState(() {
        _selectedHospital = null;
      });
    }
  }

  Future<void> _fetchRelativeOptions(String query) async {
    try {
      final repository = context.read<RecordRepository>();
      final results = await repository.searchPatientProfiles(query);
      if (!mounted || query != _lastRelativeQuery) return;
      setState(() {
        _relativeOptions = results;
      });
    } catch (_) {
      if (!mounted || query != _lastRelativeQuery) return;
      setState(() {
        _relativeOptions = <ProfileSearchResponse>[];
      });
    }
  }

  bool _equalsIgnoreCase(String a, String b) =>
      a.toLowerCase() == b.toLowerCase();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showNotification(
        color: Colors.redAccent,
        icon: Icons.error_outline,
        message: 'Vui lòng kiểm tra lại các trường thông tin bắt buộc.',
      );
      return;
    }

    if (_selectedRelative == null) {
      _showNotification(
        color: Colors.redAccent,
        icon: Icons.error_outline,
        message: 'Vui lòng chọn hồ sơ bệnh nhân trước.',
      );
      return;
    }
    if (_examDate == null) {
      _showNotification(
        color: Colors.redAccent,
        icon: Icons.error_outline,
        message: 'Vui lòng chọn ngày khám.',
      );
      return;
    }
    if (_selectedHospital == null) {
      _showNotification(
        color: Colors.redAccent,
        icon: Icons.error_outline,
        message: 'Vui lòng chọn bệnh viện / cơ sở y tế.',
      );
      return;
    }
    if (_diagnostics.isEmpty) {
      _showNotification(
        color: Colors.redAccent,
        icon: Icons.error_outline,
        message: 'Vui lòng thêm ít nhất một chẩn đoán.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = context.read<RecordRepository>();

      final diagPayloads = <Map<String, dynamic>>[];

      String mappedType = 'INITIAL';
      if (_examType == 'Khám mới') mappedType = 'INITIAL';
      else if (_examType == 'Tái khám') mappedType = 'FOLLOW_UP';
      else if (_examType == 'Khám định kỳ') mappedType = 'ROUTINE_BACKUP';

      for (var diag in _diagnostics) {
        final imageUrls = <String>[];
        for (var file in diag.images) {
          final url = await repository.uploadDiagnosticImage(file);
          if (url != null) imageUrls.add(url);
        }
        diagPayloads.add({
          'category': diag.categoryController.text,
          'tag': diag.tags.join(', '),
          'type': mappedType,
          'data': diag.dataController.text.isNotEmpty ? diag.dataController.text : _noteController.text,
          'imageUrls': imageUrls,
        });
      }

      final Set<String> encounterTags = {};
      for (var diag in _diagnostics) {
        encounterTags.addAll(diag.tags);
      }

      final payload = {
        'patientProfileId': _selectedRelative!.id,
        'title': _titleController.text,
        'note': _noteController.text,
        'hospitalId': _selectedHospital?.id,
        'datetimeEnd': _examDate?.toIso8601String(),
        'tag': encounterTags.join(', '),
        'diagnostics': diagPayloads,
      };

      final success = await repository.createFullMedicalRecord(payload);
      if (success) {
        if (mounted) {
          _showNotification(
            color: Colors.green,
            icon: Icons.check_circle_outline,
            message: 'Tạo hồ sơ thành công!',
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          _showNotification(
            color: Colors.redAccent,
            icon: Icons.error_outline,
            message: 'Tạo hồ sơ thất bại.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showNotification(
          color: Colors.redAccent,
          icon: Icons.error_outline,
          message: 'Đã xảy ra lỗi khi tạo hồ sơ. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: _textMain,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tạo bệnh án mới',
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: _primaryBlue, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(Icons.group_outlined, 'THÔNG TIN BỆNH NHÂN'),
                  const SizedBox(height: 12),
                  if (_selectedRelative == null)
                    _buildPatientSearchInput()
                  else
                    _buildPatientCard(),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(Icons.calendar_today_outlined, 'NGÀY KHÁM'),
                            const SizedBox(height: 8),
                            _buildDateInput(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(Icons.access_time_outlined, 'LOẠI KHÁM'),
                            const SizedBox(height: 8),
                            _buildTypeDropdown(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionLabel(Icons.description_outlined, 'TIÊU ĐỀ HỒ SƠ BỆNH ÁN'),
                  const SizedBox(height: 8),
                  _buildTextInput(
                    controller: _titleController,
                    hint: 'VD: Hồ sơ theo dõi sức khỏe tổng quát định kì',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionLabel(Icons.domain_outlined, 'BỆNH VIỆN / CƠ SỞ Y TẾ'),
                  const SizedBox(height: 8),
                  _buildHospitalSelector(),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel(Icons.medical_information_outlined, 'DANH MỤC CHẨN ĐOÁN'),
                      GestureDetector(
                        onTap: _addDiagnostic,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Thêm chẩn đoán',
                            style: TextStyle(
                              color: _primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._diagnostics.asMap().entries.map((e) => _buildDiagnosticCard(e.key, e.value)),

                  const SizedBox(height: 24),
                  _buildSectionLabel(Icons.assignment_outlined, 'GHI CHÚ BÁC SĨ'),
                  const SizedBox(height: 8),
                  _buildTextInput(
                    controller: _noteController,
                    hint: 'Nhập ghi chú thêm về quá trình điều trị, dặn dò bệnh nhân...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Hủy', style: TextStyle(color: _textMuted, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Hoàn tất', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(color: Colors.black.withOpacity(0.1)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _textMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Autocomplete<ProfileSearchResponse>(
        displayStringForOption: (option) => option.fullName,
        optionsBuilder: (TextEditingValue textEditingValue) {
          final query = textEditingValue.text;
          if (query.isEmpty) {
            return const Iterable<ProfileSearchResponse>.empty();
          }
          final lowerQuery = query.toLowerCase();
          return _relativeOptions.where(
            (option) =>
                option.fullName.toLowerCase().contains(lowerQuery) ||
                option.phoneNumber.toLowerCase().contains(lowerQuery) ||
                option.identityNumber.toLowerCase().contains(lowerQuery),
          );
        },
        onSelected: (ProfileSearchResponse selection) {
          setState(() {
            _selectedRelative = selection;
            _relativeOptions = <ProfileSearchResponse>[];
          });
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 250,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      onTap: () => onSelected(option),
                      leading: CircleAvatar(
                        backgroundImage: option.avatarUrl.isNotEmpty
                            ? NetworkImage(option.avatarUrl)
                            : null,
                        child: option.avatarUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        option.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Ngày sinh: ${option.dateOfBirth} - ${formatRelationshipLabel(option.relationship)}',
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
              if (_relativeFieldController != textEditingController) {
                _relativeFieldController?.removeListener(
                  _handleRelativeQueryChanged,
                );
                _relativeFieldController = textEditingController;
                _relativeFieldController!.addListener(
                  _handleRelativeQueryChanged,
                );
              }

              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm bệnh nhân theo tên/SĐT/CCCD',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                  suffixIcon:
                      _selectedRelative != null ||
                          textEditingController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            textEditingController.clear();
                            setState(() {
                              _selectedRelative = null;
                              _relativeOptions = <ProfileSearchResponse>[];
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                validator: (v) =>
                    _selectedRelative == null ? 'Vui lòng chọn bệnh nhân' : null,
                onFieldSubmitted: (_) => onFieldSubmitted(),
              );
            },
      ),
    );
  }

  Widget _buildPatientCard() {
    final rel = _selectedRelative!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _bgLight,
                    backgroundImage: rel.avatarUrl.isNotEmpty ? NetworkImage(rel.avatarUrl) : null,
                    child: rel.avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.grey, size: 30) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rel.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() {
                  _selectedRelative = null;
                  _relativeFieldController?.clear();
                }),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  side: const BorderSide(color: Color(0xFFDDE6FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Thay đổi', style: TextStyle(color: Color(0xFF246BFF), fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPatientInfoItem('NGÀY SINH', _formatDateOfBirth(rel.dateOfBirth))),
              Expanded(child: _buildPatientInfoItem('SỐ CCCD', rel.identityNumber)),
            ],
          ),
          const SizedBox(height: 16),
          _buildPatientInfoItem('ĐIỆN THOẠI', rel.phoneNumber),
          const SizedBox(height: 16),
          _buildPatientInfoItem('ĐỊA CHỈ THƯỜNG TRÚ', rel.address),
        ],
      ),
    );
  }

  String _formatDateOfBirth(String dob) {
    if (dob.trim().isEmpty) return '';
    try {
      if (dob.contains('-') && dob.length >= 10) {
        final parts = dob.split('-');
        if (parts.length >= 3) {
          return '${parts[2].substring(0, 2)}/${parts[1]}/${parts[0]}';
        }
      }
      return dob;
    } catch (_) {
      return dob;
    }
  }

  Widget _buildPatientInfoItem(String label, String value) {
    final displayValue = value.trim().isEmpty ? '' : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(displayValue, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  Widget _buildDateInput() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _examDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _examDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _examDate != null ? '${_examDate!.day.toString().padLeft(2, '0')}/${_examDate!.month.toString().padLeft(2, '0')}/${_examDate!.year}' : 'Chọn ngày',
              style: TextStyle(fontSize: 14, color: _examDate != null ? Colors.black87 : Colors.grey.shade400),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _examType,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
          items: ['Khám mới', 'Tái khám', 'Khám định kỳ'].map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _examType = val!),
        ),
      ),
    );
  }

  Widget _buildTextInput({required TextEditingController controller, required String hint, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildHospitalSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _selectedHospital != null
          ? Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF0F6FF), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.business, color: _primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_selectedHospital!.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedHospital = null;
                        _hospitalFieldController?.clear();
                        _isHospitalDropdownOpen = true;
                      });
                    },
                  ),
                ],
              ),
            )
          : Column(
              children: [
                TextField(
                  controller: _hospitalFieldController,
                  onChanged: (v) {
                    setState(() => _isHospitalDropdownOpen = true);
                    _handleHospitalQueryChanged();
                  },
                  onTap: () => setState(() => _isHospitalDropdownOpen = true),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bệnh viện...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                if (_isHospitalDropdownOpen) ...[
                  Divider(height: 1, color: Colors.grey.shade200),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Danh sách gợi ý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _textMain)),
                              Icon(Icons.keyboard_arrow_down, size: 18, color: _textMuted),
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _hospitals.length,
                            itemBuilder: (context, idx) {
                              final h = _hospitals[idx];
                              if (_hospitalFieldController != null && _hospitalFieldController!.text.isNotEmpty) {
                                if (!h.name.toLowerCase().contains(_hospitalFieldController!.text.toLowerCase())) return const SizedBox();
                              }
                              return InkWell(
                                onTap: () => setState(() {
                                  _selectedHospital = h;
                                  _isHospitalDropdownOpen = false;
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: const Color(0xFFF0F6FF), borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.business, color: Color(0xFF6B7280), size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(h.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
    );
  }

  Widget _buildDiagnosticCard(int index, DiagnosticFormModel diag) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(Icons.label_important_outline, 'TÊN CHẨN ĐOÁN'),
              const SizedBox(height: 8),
              _buildTextInput(
                controller: diag.categoryController,
                hint: 'Nhập tên chẩn đoán (VD: Viêm họng cấp tính)',
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên chẩn đoán' : null,
              ),

              const SizedBox(height: 16),
              _buildSectionLabel(Icons.local_offer_outlined, 'NHÃN PHÂN LOẠI (TAGS)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...diag.tags.map((tag) => _buildTag(tag, () {
                    setState(() => diag.tags.remove(tag));
                  })),
                  GestureDetector(
                    onTap: () => _showAddTagDialog(diag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: _textMuted),
                          const SizedBox(width: 4),
                          Text('Thêm', style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionLabel(Icons.attach_file_outlined, 'TỆP ĐÍNH KÈM CHẨN ĐOÁN'),
                  Text('Tải lên file (${diag.images.length})', style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickImages(index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(
                    painter: _DashedBorderPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (diag.images.isNotEmpty) ...[
                          SizedBox(
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: diag.images.length,
                              itemBuilder: (ctx, i) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: const EdgeInsets.only(right: 8, top: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(image: FileImage(diag.images[i]), fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeDiagnosticImage(index, i),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        const Icon(Icons.add, color: Color(0xFF60A5FA)),
                        const SizedBox(height: 4),
                        Text('Chọn ảnh hoặc PDF', style: TextStyle(color: _textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
             onTap: () => _removeDiagnostic(index),
             child: Container(
               width: 28,
               height: 28,
               decoration: BoxDecoration(
                 color: const Color(0xFFEF4444),
                 shape: BoxShape.circle,
                 border: Border.all(color: Colors.white, width: 2),
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
               ),
               child: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
             ),
          ),
        ),
      ],
    );
  }

  static const List<Color> _tagColors = [
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // amber
    Color(0xFF3B82F6), // blue
    Color(0xFFEF4444), // red
    Color(0xFF8B5CF6), // purple
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFFF97316), // orange
    Color(0xFF6366F1), // indigo
    Color(0xFF14B8A6), // teal
  ];

  static final Map<String, Color> _assignedTagColors = {};

  Widget _buildTag(String label, VoidCallback onRemove) {
    if (!_assignedTagColors.containsKey(label)) {
      _assignedTagColors[label] = _tagColors[Random().nextInt(_tagColors.length)];
    }
    final color = _assignedTagColors[label]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          GestureDetector(onTap: onRemove, child: Icon(Icons.close, size: 14, color: color.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  void _showAddTagDialog(DiagnosticFormModel diag) {
    String newTag = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm nhãn (Tag)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          onChanged: (v) => newTag = v,
          decoration: const InputDecoration(hintText: 'Nhập tên nhãn'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (newTag.trim().isNotEmpty) {
                setState(() => diag.tags.add(newTag.trim()));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showNotification({
    required Color color,
    required IconData icon,
    required String message,
  }) {
    final isError =
        icon == Icons.error_outline ||
        color == Colors.redAccent ||
        color == Colors.red;
    if (isError) {
      AppNotifier.error(context, message);
      return;
    }
    AppNotifier.success(context, message);
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(10)));

    final dashWidth = 5.0;
    final dashSpace = 4.0;
    double pathLength = 0.0;

    for (PathMetric measurePath in path.computeMetrics()) {
      while (pathLength < measurePath.length) {
        canvas.drawPath(
          measurePath.extractPath(pathLength, pathLength + dashWidth),
          paint
        );
        pathLength += dashWidth + dashSpace;
      }
      pathLength = 0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
