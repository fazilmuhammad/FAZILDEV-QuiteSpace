import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final String? imageUrl;
  final bool read;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.imageUrl,
    this.read = false,
    required this.createdAt,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'],
      senderId: data['senderId'],
      content: data['content'],
      imageUrl: data['imageUrl'],
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'imageUrl': imageUrl,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}