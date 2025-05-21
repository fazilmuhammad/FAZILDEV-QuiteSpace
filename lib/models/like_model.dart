import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory LikeModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikeModel(
      id: doc.id,
      postId: data['postId'],
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}