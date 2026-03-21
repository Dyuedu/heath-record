import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/viewmodels/record_view_model.dart';

class CreateRecordPage extends StatefulWidget {
  final String patientProfileId;

  const CreateRecordPage({super.key, required this.patientProfileId});

  @override
  State<CreateRecordPage> createState() => _CreateRecordPageState();
}

class _CreateRecordPageState extends State<CreateRecordPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Mặc định chọn loại hồ sơ là 'Test'
  String _selectedType = 'Test';
  String? _lastNotifiedError;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecordViewModel(
        repository: RecordRepository(dioClient: context.read<DioClient>()),
      )..selectedPatientProfileId = widget.patientProfileId,
      child: Consumer<RecordViewModel>(
        builder: (context, vm, child) {
          final errorMessage = vm.errorMessage;
          if (errorMessage != null && errorMessage != _lastNotifiedError) {
            _lastNotifiedError = errorMessage;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              AppNotifier.error(context, errorMessage);
              context.read<RecordViewModel>().clearError();
            });
          } else if (errorMessage == null) {
            _lastNotifiedError = null;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                "Tạo bệnh án mới",
                style: TextStyle(
                  color: Color(0xFF246BFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Phân loại hồ sơ (Type Selector)
                      _label("Phân loại hồ sơ"),
                      _buildTypeSelector(),
                      const SizedBox(height: 24),

                      // 2. Tiêu đề
                      _label("Tiêu đề khám"),
                      _textField(
                        _titleController,
                        "Nhập tiêu đề (vd: Khám tai mũi họng...)",
                      ),
                      const SizedBox(height: 24),

                      // 3. Quản lý Tags
                      _label("Từ khóa (Tags)"),
                      _buildTagSearchBar(vm),
                      const SizedBox(height: 12),
                      _buildSuggestedTags(vm),
                      const SizedBox(height: 24),

                      // 4. Hình ảnh đính kèm
                      _label("Hình ảnh & Tài liệu"),
                      _buildUploadSection(vm),
                      const SizedBox(height: 24),

                      // 5. Ghi chú
                      _label("Ghi chú của bác sĩ"),
                      _textField(
                        _notesController,
                        "Nhập nội dung chi tiết...",
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),

                      // 6. Đánh dấu quan trọng
                      _importanceSwitch(vm),
                    ],
                  ),
                ),

                // Nút Lưu nằm cố định phía dưới
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _saveButton(context, vm),
                ),

                if (vm.isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF246BFF),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildTypeSelector() {
    final types = [
      {'label': 'Xét nghiệm', 'value': 'Test', 'icon': Icons.science_outlined},
      {
        'label': 'Đơn thuốc',
        'value': 'Prescription',
        'icon': Icons.medication_outlined,
      },
      {
        'label': 'Chẩn đoán',
        'value': 'Diagnosis',
        'icon': Icons.assignment_outlined,
      },
    ];

    return Wrap(
      spacing: 10,
      children: types.map((type) {
        final bool isSelected = _selectedType == type['value'];
        return ChoiceChip(
          label: Text(type['label'] as String),
          avatar: Icon(
            type['icon'] as IconData,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF246BFF),
          ),
          selected: isSelected,
          selectedColor: const Color(0xFF246BFF),
          onSelected: (selected) {
            if (selected)
              setState(() => _selectedType = type['value'] as String);
          },
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagSearchBar(RecordViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ...vm.selectedTags.map(
            (tag) => Chip(
              label: Text(
                tag,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: const Color(0xFF246BFF),
              onDeleted: () => vm.removeTag(tag),
              deleteIcon: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  vm.addTag(value.trim());
                }
              },
              decoration: const InputDecoration(
                hintText: "Thêm tag...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedTags(RecordViewModel vm) {
    final suggested = ["Máu", "Tiểu đường", "Tim mạch", "Dị ứng"];
    return Wrap(
      spacing: 8,
      children: suggested
          .where((t) => !vm.selectedTags.contains(t))
          .map(
            (tag) => ActionChip(
              label: Text("#$tag", style: const TextStyle(fontSize: 12)),
              onPressed: () => vm.addTag(tag),
              backgroundColor: Colors.white,
              shape: const StadiumBorder(
                side: BorderSide(color: Color(0xFFDDE3FF)),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildUploadSection(RecordViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            _uploadBox(
              Icons.camera_alt_outlined,
              "Máy ảnh",
              onTap: vm.pickFromCamera,
            ),
            const SizedBox(width: 15),
            _uploadBox(Icons.image_outlined, "Thư viện", onTap: vm.pickFiles),
          ],
        ),
        if (vm.selectedFiles.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vm.selectedFiles.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(vm.selectedFiles[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => vm.removeFile(index),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _saveButton(BuildContext context, RecordViewModel vm) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF246BFF),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
      ),
      onPressed: () async {
        final success = await vm.saveDoctorRecord(
          _titleController.text,
          _notesController.text,
          _selectedType, // Truyền Type đã chọn vào hàm save
        );
        if (success && context.mounted) {
          AppNotifier.success(context, "Lưu bệnh án thành công!");
          Navigator.pop(context, true); // Trả về true để màn hình trước refresh
        }
      },
      child: const Text(
        "LƯU HỒ SƠ",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2A44),
        fontSize: 15,
      ),
    ),
  );

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _uploadBox(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDE3FF)),
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFFBFBFF),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF246BFF), size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4A5C8A)),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _importanceSwitch(RecordViewModel vm) => Row(
    children: [
      Switch(
        value: vm.isImportant,
        activeThumbColor: const Color(0xFF246BFF),
        onChanged: (v) => vm.toggleImportance(v),
      ),
      const Text(
        "Đánh dấu hồ sơ quan trọng",
        style: TextStyle(color: Color(0xFF4A5C8A), fontWeight: FontWeight.w500),
      ),
    ],
  );
}
