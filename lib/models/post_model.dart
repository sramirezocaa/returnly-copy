class PostModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}