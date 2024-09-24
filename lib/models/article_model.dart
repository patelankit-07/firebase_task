import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String userId;
  final String content;
  final String? imageUrl;
  final List<String> likedBy;
  final int likes;
  final List<dynamic> comments;

  Article({
    required this.id,
    required this.title,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.likedBy,
    required this.likes,
    required this.comments,
  });

  factory Article.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments']??List<Map>,
    );
  }
}
