class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
