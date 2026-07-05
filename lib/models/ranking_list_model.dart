class RankingListModel {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final int itemsCount;

  RankingListModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    this.itemsCount = 0,
  });

  factory RankingListModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RankingListModel(
      id: documentId,
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      itemsCount: map['itemsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'itemsCount': itemsCount,
    };
  }

  RankingListModel copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    int? itemsCount,
  }) {
    return RankingListModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }
}
