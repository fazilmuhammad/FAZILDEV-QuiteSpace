import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String content;
  final String? imageUrl;
  final String privacy; // 'public', 'friends', 'private'
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.privacy = 'public',
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    required this.createdAt,
  });

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      userId: data['userId'],
      content: data['content'],
      imageUrl: data['imageUrl'],
      privacy: data['privacy'] ?? 'public',
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'privacy': privacy,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}