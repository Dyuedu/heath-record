import 'package:flutter/material.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/viewmodels/record_view_model.dart';
import 'package:provider/provider.dart';

class CreateRecordPage extends StatelessWidget {
  CreateRecordPage({super.key, required this.relativeId});

  final String relativeId;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Khởi tạo ViewModel
    return ChangeNotifierProvider(
      create: (context) => RecordViewModel(
        repository: RecordRepository(dioClient: context.read<DioClient>()),
      ),
      child: Consumer<RecordViewModel>(
        builder: (context, vm, child) {
          vm.selectedRelativeId ??= relativeId;
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Add New Record",
                style: TextStyle(
                  color: Color(0xFF246BFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Title"),
                      _textField(_titleController, "Enter record title..."),
                      if (vm.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      _label("Tags Management"),
                      _buildTagSearchBar(vm),
                      const SizedBox(height: 10),
                      _buildSuggestedTags(vm),
                      const SizedBox(height: 20),

                      _label("Attachments (Photo/Docs)"),
                      _buildUploadSection(vm),
                      const SizedBox(height: 20),

                      _label("Notes"),
                      _textField(
                        _notesController,
                        "Add some notes here...",
                        maxLines: 3,
                      ),

                      _importanceSwitch(vm),
                      const SizedBox(height: 30),

                      _saveButton(context, vm),
                    ],
                  ),
                ),
                if (vm.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildTagSearchBar(RecordViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE3FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Wrap(
        spacing: 8,
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
          const SizedBox(
            width: 100,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tag...",
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
    final suggested = ["Blood", "Diabetes", "Heart", "COVID-19", "Allergy"];
    return Wrap(
      spacing: 8,
      children: suggested
          .where((t) => !vm.selectedTags.contains(t))
          .map(
            (tag) => ActionChip(
              label: Text("#$tag"),
              onPressed: () => vm.addTag(tag),
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
            _uploadBox(Icons.camera_alt, "Camera", onTap: vm.pickFromCamera),
            const SizedBox(width: 15),
            _uploadBox(Icons.file_present, "Files", onTap: vm.pickFiles),
          ],
        ),
        if (vm.selectedFiles.isNotEmpty) _previewGrid(vm),
      ],
    );
  }

  Widget _previewGrid(RecordViewModel vm) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vm.selectedFiles.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                width: 90,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFFDDE3FF),
                  image: DecorationImage(
                    image: FileImage(
                      vm.selectedFiles[index],
                    ), // HIỂN THỊ FILE THẬT
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 12,
                child: GestureDetector(
                  onTap: () => vm.removeFile(index),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _saveButton(BuildContext context, RecordViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF246BFF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const StadiumBorder(),
        ),
        onPressed: () async {
          final success = await vm.saveRecord(
            _titleController.text,
            _notesController.text,
          );
          final messenger = ScaffoldMessenger.of(context);
          if (success) {
            _titleController.clear();
            _notesController.clear();
            Navigator.of(context).pop(true);
          } else if (vm.errorMessage != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(vm.errorMessage!)),
            );
          }
        },
        child: const Text(
          "Save Record",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF246BFF),
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
      fillColor: const Color(0xFFDDE3FF).withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
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
          border: Border.all(color: const Color(0xFF246BFF)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF246BFF)),
            Text(label),
          ],
        ),
      ),
    ),
  );

  Widget _importanceSwitch(RecordViewModel vm) => Row(
    children: [
      Checkbox(
        value: vm.isImportant,
        activeColor: const Color(0xFF246BFF),
        onChanged: (v) => vm.toggleImportance(v!),
      ),
      const Text(
        "Mark as important record",
        style: TextStyle(color: Color(0xFF246BFF)),
      ),
    ],
  );
}
