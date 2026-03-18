import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/doctor_ui_helpers.dart';

class DiagnosticCard extends StatelessWidget {
  final int index;
  final TextEditingController categoryController;
  final TextEditingController tagController;
  final TextEditingController dataController;
  final List<File> images;
  final VoidCallback onRemove;
  final Future<void> Function() onPickImages;
  final void Function(int imageIndex) onRemoveImage;

  const DiagnosticCard({
    super.key,
    required this.index,
    required this.categoryController,
    required this.tagController,
    required this.dataController,
    required this.images,
    required this.onRemove,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: DoctorUIHelpers.softShadow(blur: 18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NumberBadge(number: index + 1),
              const SizedBox(width: 12),
              Text('Chẩn đoán #${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Xóa'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: categoryController,
            label: 'Nhóm chẩn đoán',
            icon: Icons.category,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: tagController,
            label: 'Thẻ nhãn',
            icon: Icons.label,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: dataController,
            label: 'Dữ liệu / Kết quả',
            icon: Icons.analytics,
            maxLines: 2,
          ),
          const SizedBox(height: 18),
          _buildImagePicker(context),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                images.length,
                (imageIndex) => _ImagePreview(
                  file: images[imageIndex],
                  onRemove: () => onRemoveImage(imageIndex),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ''}',
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: AppTheme.primaryLight.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
      validator: required ? (value) => (value == null || value.isEmpty) ? 'Không được để trống' : null : null,
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final hasImages = images.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ElevatedButton.icon(
          onPressed: onPickImages,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          icon: const Icon(Icons.image_outlined),
          label: const Text('Thêm hình ảnh'),
        ),
        if (hasImages)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${images.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  const _NumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor,
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString().padLeft(2, '0'),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _ImagePreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
