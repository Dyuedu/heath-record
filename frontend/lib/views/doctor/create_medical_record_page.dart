import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/hospital_response.dart';
import 'package:frontend/data/models/relative_search_response.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/utils/app_notifier.dart';
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

  void dispose() {
    categoryController.dispose();
    tagController.dispose();
    dataController.dispose();
  }
}

class CreateMedicalRecordPage extends StatefulWidget {
  const CreateMedicalRecordPage({super.key});

  @override
  State<CreateMedicalRecordPage> createState() =>
      _CreateMedicalRecordPageState();
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

  @override
  void initState() {
    super.initState();
    _diagnostics.add(DiagnosticFormModel());
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedRelative == null) {
      _showNotification(
        color: Colors.redAccent,
        icon: Icons.error_outline,
        message: 'Vui lòng chọn hồ sơ bệnh nhân trước.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = context.read<RecordRepository>();

      final diagPayloads = <Map<String, dynamic>>[];
      for (var diag in _diagnostics) {
        final imageUrls = <String>[];
        for (var file in diag.images) {
          final url = await repository.uploadDiagnosticImage(file);
          if (url != null) imageUrls.add(url);
        }
        diagPayloads.add({
          'category': diag.categoryController.text,
          'tag': diag.tagController.text,
          'data': diag.dataController.text,
          'imageUrls': imageUrls,
        });
      }

      final payload = {
        'patientProfileId': _selectedRelative!.id,
        'title': _titleController.text,
        'note': _noteController.text,
        'hospitalId': _selectedHospital?.id,
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: const Text(
          'Tạo hồ sơ y tế',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scrollView = SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      child: RecordSectionHeader(
                        title: 'Thông tin chung',
                        subtitle:
                            'Hoàn thiện các thông tin cơ bản trước khi thêm chẩn đoán.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _titleController,
                      'Tiêu đề hồ sơ',
                      Icons.title,
                      required: true,
                    ),
                    const SizedBox(height: 12),
                    _buildRelativeSearch(),
                    const SizedBox(height: 12),
                    _buildHospitalSearch(),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _noteController,
                      'Ghi chú chung',
                      Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: RecordSectionHeader(
                            title: 'Chẩn đoán',
                            subtitle: 'Thêm các ghi nhận chi tiết',
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addDiagnostic,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.primaryColor,
                          ),
                          label: const Text(
                            'Thêm',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_diagnostics.isEmpty)
                      const Text(
                        'Chưa có chẩn đoán nào.',
                        style: TextStyle(color: AppTheme.captionTextColor),
                      )
                    else
                      ..._diagnostics.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final diag = entry.value;
                        return DiagnosticCard(
                          index: idx,
                          categoryController: diag.categoryController,
                          tagController: diag.tagController,
                          dataController: diag.dataController,
                          images: diag.images,
                          onRemove: () => _removeDiagnostic(idx),
                          onPickImages: () => _pickImages(idx),
                          onRemoveImage: (imageIdx) =>
                              _removeDiagnosticImage(idx, imageIdx),
                        );
                      }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Lưu hồ sơ y tế'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );

          if (constraints.hasBoundedHeight) {
            return scrollView;
          }

          final fallbackHeight = MediaQuery.of(context).size.height;
          return SizedBox(height: fallbackHeight, child: scrollView);
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        label: required ? _buildRequiredLabel(label) : Text(label),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: AppTheme.primaryLight.withOpacity(0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      validator: required
          ? ((v) => (v == null || v.isEmpty) ? 'Không được để trống' : null)
          : null,
    );
  }

  Widget _buildRelativeSearch() {
    return Autocomplete<ProfileSearchResponse>(
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
              option.phoneNumber.toLowerCase().contains(lowerQuery),
        );
      },
      onSelected: (ProfileSearchResponse selection) {
        setState(() {
          _selectedRelative = selection;
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              height: 250.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () => onSelected(option),
                    child: ListTile(
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
                        'Ngày sinh: ${option.dateOfBirth} - ${option.relationship}',
                      ),
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
                label: _buildRequiredLabel('Bệnh nhân / Người thân (tìm theo tên/số ĐT)'),
                prefixIcon: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                ),
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
                filled: true,
                fillColor: AppTheme.primaryLight.withOpacity(0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  _selectedRelative == null ? 'Vui lòng chọn bệnh nhân' : null,
            );
          },
    );
  }

  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: AppTheme.bodyTextColor),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalSearch() {
    return Autocomplete<HospitalResponse>(
      displayStringForOption: (option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _hospitals;
        }
        return _hospitals.where(
          (HospitalResponse option) => option.name.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          ),
        );
      },
      onSelected: (HospitalResponse selection) {
        setState(() {
          _selectedHospital = selection;
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              height: 200.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            if (_hospitalFieldController != textEditingController) {
              _hospitalFieldController?.removeListener(
                _handleHospitalQueryChanged,
              );
              _hospitalFieldController = textEditingController;
              _hospitalFieldController!.addListener(
                _handleHospitalQueryChanged,
              );
            }
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Bệnh viện (tìm theo tên)',
                prefixIcon: const Icon(
                  Icons.local_hospital,
                  color: AppTheme.primaryColor,
                ),
                suffixIcon:
                    _selectedHospital != null ||
                        textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          textEditingController.clear();
                          setState(() => _selectedHospital = null);
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.primaryLight.withOpacity(0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          },
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
