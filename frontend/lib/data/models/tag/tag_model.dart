class TagModel {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  TagModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}
