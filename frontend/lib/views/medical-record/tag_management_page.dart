import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';

class TagManagementPage extends StatefulWidget {
  const TagManagementPage({super.key});

  @override
  State<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends State<TagManagementPage> {
  // Tags đã chọn
  List<String> selectedTags = ["Blood", "Urgent"];
  // Tags gợi ý phổ biến (từ database)
  List<String> popularTags = [
    "Heart",
    "Diabetes",
    "COVID-19",
    "Allergy",
    "Routine",
    "Flu",
    "Imaging",
    "Medication",
  ];
  // Tags gợi ý dựa trên tìm kiếm (từ database/backend)
  List<String> searchSuggestions = [];

  String currentSearchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Manage Tags",
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF246BFF)),
          onPressed: () => Navigator.pop(context, selectedTags),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, selectedTags),
            child: const Text(
              "Done",
              style: TextStyle(
                color: Color(0xFF246BFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thanh tìm kiếm và Tags đã chọn (Search & Selected Tags)
          _buildSearchAndSelectedTags(),

          const Divider(height: 1),

          // 2. Khu vực Gợi ý Tags (Suggestions Area)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút thêm tag mới (chỉ hiện khi có nội dung tìm kiếm và không trùng)
                  if (currentSearchQuery.isNotEmpty &&
                      !_isTagExist(currentSearchQuery))
                    _buildAddNewTagButton(),

                  const SizedBox(height: 16),

                  // Tiêu đề phần gợi ý
                  Text(
                    currentSearchQuery.isEmpty ? "Popular Tags" : "Suggestions",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Danh sách gợi ý (Popular hoặc Search Results)
                  _buildTagSuggestionsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Components ---

  Widget _buildSearchAndSelectedTags() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFDDE3FF).withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị Tags đã chọn dạng Chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: selectedTags
                .map(
                  (tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFF246BFF),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                    onDeleted: () => setState(() => selectedTags.remove(tag)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                  ),
                )
                .toList(),
          ),

          if (selectedTags.isNotEmpty) const SizedBox(height: 8),

          // Thanh nhập liệu tìm kiếm (Input Field)
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                currentSearchQuery = value.trim();
                // Giả lập logic tìm kiếm backend: gợi ý tag chứa nội dung
                searchSuggestions = popularTags
                    .where(
                      (tag) =>
                          tag.toLowerCase().contains(
                            currentSearchQuery.toLowerCase(),
                          ) &&
                          !selectedTags.contains(tag),
                    )
                    .toList();
              });
            },
            decoration: InputDecoration(
              hintText: "Search or enter new tag...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF246BFF)),
              suffixIcon: currentSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          currentSearchQuery = "";
                          searchSuggestions = [];
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              hintStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewTagButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, color: Colors.white, size: 18),
        label: Text(
          "Add new tag: \"$currentSearchQuery\"",
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF246BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        onPressed: () {
          // Logic thêm tag mới vào list và database (backend xử lý LOWER(), TRIM())
          setState(() {
            selectedTags.add(currentSearchQuery);
            _searchController.clear();
            currentSearchQuery = "";
            searchSuggestions = [];
          });
          AppNotifier.success(context, "Đã thêm thẻ tùy chỉnh mới!");
        },
      ),
    );
  }

  Widget _buildTagSuggestionsList() {
    // Hiển thị Popular Tags khi không search, hiển thị Search Suggestions khi đang search
    List<String> tagsToDisplay = currentSearchQuery.isEmpty
        ? popularTags
        : searchSuggestions;

    // Loại bỏ các tag đã được chọn khỏi danh sách hiển thị
    tagsToDisplay = tagsToDisplay
        .where((tag) => !selectedTags.contains(tag))
        .toList();

    if (tagsToDisplay.isEmpty && currentSearchQuery.isNotEmpty) {
      return const Center(
        child: Text(
          "No suggestions found.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: tagsToDisplay
          .map(
            (tag) => ActionChip(
              label: Text(
                "#$tag",
                style: const TextStyle(color: Color(0xFF246BFF), fontSize: 13),
              ),
              backgroundColor: const Color(0xFFDDE3FF),
              shape: StadiumBorder(
                side: BorderSide(color: const Color(0xFFDDE3FF)),
              ),
              onPressed: () {
                setState(() {
                  selectedTags.add(tag);
                  if (currentSearchQuery.isNotEmpty) {
                    _searchController.clear();
                    currentSearchQuery = "";
                    searchSuggestions = [];
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }

  // Hàm kiểm tra tag đã tồn tại chưa (so khớp không phân biệt hoa thường)
  bool _isTagExist(String newTag) {
    return popularTags.any(
          (tag) => tag.toLowerCase() == newTag.toLowerCase(),
        ) ||
        selectedTags.any((tag) => tag.toLowerCase() == newTag.toLowerCase());
  }
}
