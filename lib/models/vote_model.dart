class VoteModel {
  final String id;
  final String listId;
  final String userId;
  final String userName;
  final List<String> rankedItemIds; // Ordered item IDs: index 0 = Rank 1, index 1 = Rank 2, etc.
  final DateTime createdAt;

  VoteModel({
    required this.id,
    required this.listId,
    required this.userId,
    required this.userName,
    required this.rankedItemIds,
    required this.createdAt,
  });

  factory VoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VoteModel(
      id: documentId,
      listId: map['listId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rankedItemIds: List<String>.from(map['rankedItemIds'] ?? []),
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listId': listId,
      'userId': userId,
      'userName': userName,
      'rankedItemIds': rankedItemIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
