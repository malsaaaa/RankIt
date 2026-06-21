class ItemModel {
  final String id;
  final String listId;
  final String name;
  final String description;
  final String? imageUrl;
  final double score;       // Cumulative aggregated community score
  final int votesCount;     // How many ballots have ranked this item

  ItemModel({
    required this.id,
    required this.listId,
    required this.name,
    required this.description,
    this.imageUrl,
    this.score = 0.0,
    this.votesCount = 0,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ItemModel(
      id: documentId,
      listId: map['listId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      score: (map['score'] ?? 0.0).toDouble(),
      votesCount: map['votesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listId': listId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'score': score,
      'votesCount': votesCount,
    };
  }

  ItemModel copyWith({
    double? score,
    int? votesCount,
  }) {
    return ItemModel(
      id: id,
      listId: listId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      score: score ?? this.score,
      votesCount: votesCount ?? this.votesCount,
    );
  }
}
