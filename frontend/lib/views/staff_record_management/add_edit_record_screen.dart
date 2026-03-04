import 'package:flutter/material.dart';
import 'package:frontend/views/staff_record_management/models.dart';

class AddEditRecordScreen extends StatefulWidget {
  final MedicalRecord? record;

  const AddEditRecordScreen({this.record});

  @override
  State<AddEditRecordScreen> createState() =>
      _AddEditRecordScreenState();
}

class _AddEditRecordScreenState
    extends State<AddEditRecordScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController patientNameController;
  late TextEditingController patientCodeController;
  late TextEditingController titleController;
  late TextEditingController doctorController;
  late TextEditingController descriptionController;

  DateTime selectedDate = DateTime.now();
  String type = "Xét nghiệm";

  List<String> selectedTags = [];
  List<String> imagePaths = [];

  final List<String> availableTags = [
    "blood-test",
    "imaging",
    "cholesterol",
    "urinalysis"
  ];

  @override
  void initState() {
    super.initState();

    final r = widget.record;

    patientNameController =
        TextEditingController(text: r?.patientName ?? "");
    patientCodeController =
        TextEditingController(text: r?.patientCode ?? "");
    titleController =
        TextEditingController(text: r?.title ?? "");
    doctorController =
        TextEditingController(text: r?.doctor ?? "");
    descriptionController =
        TextEditingController(text: r?.description ?? "");

    selectedDate = r?.date ?? DateTime.now();
    type = r?.type ?? "Xét nghiệm";
    selectedTags = List.from(r?.tags ?? []);
    imagePaths = List.from(r?.imagePaths ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EC6C1),
        title: Text(isEdit ? "Chỉnh sửa hồ sơ" : "Thêm hồ sơ mới"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              _buildInput(patientNameController, "Tên bệnh nhân"),
              _buildInput(patientCodeController, "Mã bệnh nhân"),
              _buildInput(titleController, "Tiêu đề"),

              _buildDropdown(),

              _buildDatePicker(),

              _buildInput(doctorController, "Bác sĩ phụ trách"),

              _buildInput(descriptionController, "Mô tả", maxLines: 3),

              const SizedBox(height: 16),
              const Text("Tags"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6EC6C1),
                    onSelected: (_) {
                      setState(() {
                        isSelected
                            ? selectedTags.remove(tag)
                            : selectedTags.add(tag);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const Text("Hình ảnh đính kèm"),
              const SizedBox(height: 8),
              _buildImageSection(),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6EC6C1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _submit,
                child: Text(isEdit ? "Cập nhật" : "Lưu hồ sơ"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) =>
        value == null || value.isEmpty ? "Không được để trống" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: type,
        items: ["Xét nghiệm", "Chẩn đoán", "Đơn thuốc"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => setState(() => type = val!),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() => selectedDate = picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
              "Ngày khám: ${selectedDate.toLocal().toString().split(' ')[0]}"),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          children: imagePaths.map((path) {
            return Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        imagePaths.remove(path);
                      });
                    },
                    child: const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close,
                          size: 12, color: Colors.white),
                    ),
                  ),
                )
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              imagePaths.add("mock_image_${imagePaths.length}");
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Thêm ảnh (mock)"),
        )
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final record = MedicalRecord(
      id: widget.record?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: patientNameController.text,
      patientCode: patientCodeController.text,
      title: titleController.text,
      type: type,
      date: selectedDate,
      doctor: doctorController.text,
      description: descriptionController.text,
      tags: selectedTags,
      imagePaths: imagePaths,
    );

    Navigator.pop(context, record);
  }
}