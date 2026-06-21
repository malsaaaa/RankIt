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
}
