class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
