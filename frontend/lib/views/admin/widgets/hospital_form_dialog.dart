import 'package:flutter/material.dart';

class HospitalFormDialog extends StatefulWidget {
  final int? id;
  final String? initialName;

  const HospitalFormDialog({
    super.key,
    this.id,
    this.initialName,
  });

  @override
  State<HospitalFormDialog> createState() => _HospitalFormDialogState();
}

class _HospitalFormDialogState extends State<HospitalFormDialog> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.id == null ? 'Thêm Bệnh viện' : 'Cập nhật Bệnh viện',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              validator: (v) => v!.trim().isEmpty ? 'Tên bệnh viện không được để trống' : null,
              decoration: InputDecoration(
                labelText: 'Tên bệnh viện',
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
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
