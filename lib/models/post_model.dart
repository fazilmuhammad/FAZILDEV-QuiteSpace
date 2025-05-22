import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String content;
  final String privacy; // 'public', 'friends', 'private'
  final String type;
  final int likeCount;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.content,
    this.privacy = 'public',
    this.type = 'text',
    this.likeCount = 0,
    required this.createdAt,
  });

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      userId: data['userId'],
      content: data['content'],
      privacy: data['privacy'] ?? 'public',
      type: data['type'] ?? 'text',
      likeCount: data['likeCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'privacy': privacy,
      'type':type,
      'likeCount': likeCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}