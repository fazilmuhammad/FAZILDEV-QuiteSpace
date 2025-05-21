import 'package:cloud_firestore/cloud_firestore.dart';

class FollowModel {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory FollowModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FollowModel(
      id: doc.id,
      followerId: data['followerId'],
      followingId: data['followingId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}