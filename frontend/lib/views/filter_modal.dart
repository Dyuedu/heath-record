// filter_modal.dart
import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final List<String> uniqueTags = [
    "blood-test",
    "cholesterol",
    "normal-range",
    "urinalysis",
    "imaging",
    "antibiotic",
  ];

  final List<String> recordTypes = ["All", "Lab Results", "Imaging", "Prescription", "Other"];

  String dateType = "static";
  String fromDate = "";
  String toDate = "";
  String recordType = "All";
  bool starred = false;
  List<String> selectedTags = [];
  bool showMore = false;

  List<List<String>> getTagRows() {
    final displayedTags = showMore ? uniqueTags : uniqueTags.take(6).toList();
    List<List<String>> rows = [];
    for (int i = 0; i < displayedTags.length; i += 3) {
      int end = i + 3;
      if (end > displayedTags.length) end = displayedTags.length;
      rows.add(displayedTags.sublist(i, end));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lọc',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 22, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Date section
                    _buildDateSection(),

                    const Divider(height: 24),

                    // Record Type
                    _buildRecordTypeSection(),

                    const Divider(height: 24),

                    // Starred
                    _buildStarredSection(),

                    const Divider(height: 24),

                    // Tags
                    _buildTagsSection(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Footer buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              'Quay lại',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Apply filters here
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DD9D0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              'Xác nhận',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date (MM/DD/YYYY)',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // All time radio
        InkWell(
          onTap: () {
            setState(() {
              dateType = "all";
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dateType == "all" ? const Color(0xFF4DD9D0) : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: dateType == "all"
                      ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4DD9D0),
                      ),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                const Text('All time', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),

        // Static period radio
        InkWell(
          onTap: () {
            setState(() {
              dateType = "static";
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dateType == "static" ? const Color(0xFF4DD9D0) : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: dateType == "static"
                      ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4DD9D0),
                      ),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                const Text('Static period', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Date inputs
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => fromDate = value,
                        enabled: dateType == "static",
                        decoration: const InputDecoration(
                          hintText: 'From',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => toDate = value,
                        enabled: dateType == "static",
                        decoration: const InputDecoration(
                          hintText: 'to',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Record Type',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: recordType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: recordTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    recordType = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarredSection() {
    return Row(
      children: [
        const Text(
          'Starred',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            setState(() {
              starred = !starred;
            });
          },
          child: Icon(
            starred ? Icons.star : Icons.star_border,
            size: 20,
            color: starred ? Colors.amber[600] : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...getTagRows().map((row) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: row.map((tag) => Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (selectedTags.contains(tag)) {
                      selectedTags.remove(tag);
                    } else {
                      selectedTags.add(tag);
                    }
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedTags.contains(tag)
                              ? const Color(0xFF4DD9D0)
                              : Colors.grey,
                        ),
                        color: selectedTags.contains(tag)
                            ? const Color(0xFF4DD9D0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: selectedTags.contains(tag)
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        )),

        if (uniqueTags.length > 6)
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  showMore = !showMore;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showMore ? "Less" : "More",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Icon(
                      showMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}