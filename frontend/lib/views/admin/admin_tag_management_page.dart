import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/tag/tag_model.dart';
import 'package:frontend/viewmodels/admin_tag_viewmodel.dart';
import 'package:frontend/views/admin/widgets/tag_form_dialog.dart';

class AdminTagManagementPage extends StatefulWidget {
  const AdminTagManagementPage({super.key});

  @override
  State<AdminTagManagementPage> createState() => _AdminTagManagementPageState();
}

class _AdminTagManagementPageState extends State<AdminTagManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTagViewModel>().loadTags();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF1F2A44),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý Tag',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2A44),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showTagForm(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tag...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List body via Consumer
          Expanded(
            child: Consumer<AdminTagViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF246BFF)));
                }

                String search = _searchController.text.trim().toLowerCase();
                List<TagModel> tags = viewModel.tags;
                if (search.isNotEmpty) {
                  tags = tags.where((t) => t.name.toLowerCase().contains(search) || t.description.toLowerCase().contains(search)).toList();
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            'DANH SÁCH (${tags.length})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: tags.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                              itemCount: tags.length,
                              itemBuilder: (context, index) {
                                return _buildTagCard(tags[index], viewModel);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagCard(TagModel tag, AdminTagViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF246BFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_offer, color: Color(0xFF246BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tag.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1F2A44),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tag.isActive ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag.isActive ? 'Hoạt động' : 'Ngừng hoạt động',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: tag.isActive ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tag.description.isEmpty ? 'Không có mô tả' : tag.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFF59E0B), size: 22),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () => _showTagForm(context, tag: tag),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () => _showDeleteConfirm(context, tag, viewModel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Không có tag nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Danh sách trống. Hãy tạo tag đầu tiên!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagForm(BuildContext context, {TagModel? tag}) async {
    final result = await showDialog(
      context: context,
      builder: (_) => TagFormDialog(
        id: tag?.id,
        initialName: tag?.name,
        initialDescription: tag?.description,
      ),
    );

    if (result != null && mounted) {
      final viewModel = context.read<AdminTagViewModel>();
      _showLoadingOverlay(context);
      bool success;
      if (tag == null) {
        success = await viewModel.createTag(result['name'], result['description']);
      } else {
        success = await viewModel.updateTag(tag.id, result['name'], result['description']);
      }
      
      if (mounted) {
        Navigator.pop(context); // close loading overlay
        _showSnackBar(viewModel.errorMessage ?? viewModel.successMessage ?? '', !success);
      }
    }
  }

  void _showDeleteConfirm(BuildContext context, TagModel tag, AdminTagViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận vô hiệu hóa'),
        content: Text('Bạn có chắc chắn muốn vô hiệu hóa tag "${tag.name}" không? Khách hàng sẽ không thể chọn mục này nữa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingOverlay(context);
              final success = await viewModel.deleteTag(tag.id);
              if (mounted) {
                Navigator.pop(context); // close loading overlay
                _showSnackBar(viewModel.errorMessage ?? viewModel.successMessage ?? '', !success);
              }
            },
            child: const Text('Vô hiệu hóa', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF246BFF)),
      ),
    );
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
