import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String senderId;
  final String targetUserId;
  final String type; // 'like', 'comment', 'follow'
  final String? postId;
  final String? commentId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.targetUserId,
    required this.type,
    this.postId,
    this.commentId,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      senderId: data['senderId'],
      targetUserId: data['targetUserId'],
      type: data['type'],
      postId: data['postId'],
      commentId: data['commentId'],
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'targetUserId': targetUserId,
      'type': type,
      'postId': postId,
      'commentId': commentId,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}