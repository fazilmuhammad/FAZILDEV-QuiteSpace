import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: doc.id,
      userId: data['userId'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}