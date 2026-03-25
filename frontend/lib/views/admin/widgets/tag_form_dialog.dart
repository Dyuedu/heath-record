import 'package:flutter/material.dart';

class TagFormDialog extends StatefulWidget {
  final int? id;
  final String? initialName;
  final String? initialDescription;

  const TagFormDialog({
    super.key,
    this.id,
    this.initialName,
    this.initialDescription,
  });

  @override
  State<TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends State<TagFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.id == null ? 'Thêm Tag' : 'Cập nhật Tag',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              validator: (v) => v!.trim().isEmpty ? 'Tên tag không được để trống' : null,
              decoration: InputDecoration(
                labelText: 'Tên Tag',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'description': _descController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF246BFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
